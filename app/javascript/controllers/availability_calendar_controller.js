import { Controller } from "@hotwired/stimulus"
const labels = { available: "Disponible", unavailable: "Indisponible", on_request: "Sur demande", clear: "Non renseigné", unknown: "Non renseigné" }
export default class extends Controller {
  static targets = ["feedback", "mode", "day", "activate", "period", "undo"]
  connect() { this.active = this.element.dataset.editing === "true"; this.busy = false; this.refresh() }
  state() { return this.element.querySelector('input[name="paint"]:checked')?.value }
  summary() { return `${labels[this.state()]} · ${this.element.elements.area_name.value} + ${this.element.elements.travel_radius_km.value} km` }
  submit(event) { event.preventDefault() }
  refresh() {
    this.dayTargets.forEach(day => { day.disabled = !this.active || this.busy || day.dataset.past === "true" })
    this.periodTarget.disabled = !this.active || this.busy
    this.activateTarget.disabled = this.busy
    this.modeTarget.classList.toggle("is-active", this.active)
    this.modeTarget.textContent = this.active ? `Mode actif : ${this.summary()}. Cliquez sur les dates : chaque clic est enregistré immédiatement.` : "Consultation · Préparez vos paramètres puis activez l’application."
    this.updatePeriod()
  }
  parametersChanged() {
    this.active = false
    this.refresh()
    this.feedbackTarget.textContent = "Paramètres modifiés. Réactivez l’application pour continuer."
  }
  navigate(event) {
    event.preventDefault()
    if (this.busy) return
    const url = new URL(event.currentTarget.href), body = this.body()
    for (const name of ["area_name", "travel_radius_km", "paint", "replace_details", "starts_at_time", "ends_at_time", "public_note"]) url.searchParams.set(name, body.get(name) || "")
    url.searchParams.set("editing", this.active ? "1" : "0")
    window.location.assign(url.toString())
  }
  validParameters() {
    return [...this.element.querySelector(".calendar-step").querySelectorAll("input, textarea")].every(field => field.reportValidity())
  }
  async activate() {
    if (this.busy || !this.validParameters()) return
    // Reload the selected area's records before enabling editing. Preserve configuration.
    const url = new URL(window.location.href)
    const body = this.body()
    for (const name of ["area_name", "travel_radius_km", "month", "paint", "replace_details", "starts_at_time", "ends_at_time", "public_note"]) url.searchParams.set(name, body.get(name) || "")
    url.searchParams.set("editing", "1")
    if (this.element.dataset.loadedArea !== body.get("area_name")) {
      window.location.assign(url.toString()); return
    }
    this.active = true; this.feedbackTarget.textContent = "Application activée."; this.refresh()
  }
  edit() { if (this.busy) return; this.finish(); this.element.elements.area_name.focus() }
  finish() { if (this.busy) return; this.active = false; this.refresh(); this.feedbackTarget.textContent = "Application terminée. Le calendrier est en consultation." }
  body() {
    const body = new FormData(this.element)
    body.set("replace_details", this.element.querySelector('input[type="checkbox"][name="replace_details"]').checked ? "1" : "0")
    return body
  }
  async request(body) {
    const response = await fetch(this.element.action, { method: "POST", body, headers: { "Accept": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" } })
    if (response.redirected || !response.headers.get("content-type")?.includes("application/json")) throw new Error("Votre session a changé. Rechargez la page.")
    const result = await response.json()
    if (!response.ok) throw new Error(result.error || "Enregistrement impossible.")
    return result
  }
  async paint(event) {
    event.preventDefault()
    if (!this.active || this.busy) return
    const button = event.currentTarget, state = this.state(), body = this.body()
    body.set("single_date", button.value)
    this.busy = true; this.refresh(); this.feedbackTarget.textContent = "Enregistrement…"
    try {
      const result = await this.request(body)
      this.renderDay(button, state === "clear" ? "unknown" : state)
      this.lastChange = { button, token: result.undo_token }
      this.undoTarget.hidden = !result.undo_token
      this.feedbackTarget.textContent = `${this.dateLabel(button.value)} : ${labels[state]} enregistré.`
    } catch (error) { this.feedbackTarget.textContent = error.message || "Connexion interrompue. Réessayez." }
    finally { this.busy = false; this.refresh() }
  }
  dateLabel(value) { return new Date(`${value}T12:00:00`).toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" }) }
  renderDay(button, state) { button.className = `day state-${state}`; button.dataset.state = state; button.setAttribute("aria-label", `${this.dateLabel(button.value)} — ${labels[state]}`) }
  async undo() {
    if (this.busy || !this.lastChange) return
    this.busy = true; this.refresh(); this.undoTarget.disabled = true
    const body = this.body(); body.set("undo_token", this.lastChange.token)
    try { const result = await this.request(body); this.renderDay(this.lastChange.button, result.state); this.lastChange = null; this.undoTarget.hidden = true; this.feedbackTarget.textContent = "Dernière modification annulée." }
    catch (error) { this.feedbackTarget.textContent = error.message }
    finally { this.busy = false; this.undoTarget.disabled = false; this.refresh() }
  }
  periodDates() {
    const first = this.element.elements.from.value, last = this.element.elements.to.value
    if (!first || !last || last < first) return []
    const weekdays = [...this.element.querySelectorAll('input[name="weekdays[]"]:checked')].map(x => Number(x.value))
    const dates = [], end = new Date(`${last}T12:00:00`), day = new Date(`${first}T12:00:00`)
    for (let count = 0; day <= end && count < 367; count++, day.setDate(day.getDate() + 1)) if (weekdays.includes(day.getDay())) dates.push(`${day.getFullYear()}-${String(day.getMonth()+1).padStart(2,"0")}-${String(day.getDate()).padStart(2,"0")}`)
    return dates
  }
  updatePeriod() { this.periodTarget.textContent = `Appliquer « ${labels[this.state()]} » à ${this.periodDates().length} dates` }
  async period(event) {
    event.preventDefault()
    if (!this.active || this.busy || !this.element.reportValidity()) return
    const dates = this.periodDates()
    if (!dates.length || dates.length > 366) { this.feedbackTarget.textContent = "Choisissez une période de 1 à 366 jours et au moins un jour de semaine."; return }
    if (!window.confirm(`${this.summary()} : appliquer à ${dates.length} dates du ${this.dateLabel(this.element.elements.from.value)} au ${this.dateLabel(this.element.elements.to.value)} ?`)) return
    const body = this.body(); body.set("mode", "period")
    const state = this.state(); this.busy = true; this.refresh(); this.feedbackTarget.textContent = "Enregistrement de la période…"
    try { await this.request(body); this.dayTargets.filter(x => dates.includes(x.value)).forEach(x => this.renderDay(x, state === "clear" ? "unknown" : state)); this.undoTarget.hidden = true; this.lastChange = null; this.feedbackTarget.textContent = `${dates.length} dates enregistrées.` }
    catch (error) { this.feedbackTarget.textContent = error.message }
    finally { this.busy = false; this.refresh() }
  }
}
