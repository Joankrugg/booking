import { readFileSync } from 'node:fs'
import vm from 'node:vm'
import assert from 'node:assert/strict'
const code = readFileSync('app/javascript/controllers/availability_calendar_controller.js', 'utf8').replace(/^import .*\n/, '').replace('export default class', 'globalThis.Calendar = class')
const context = vm.createContext({ Controller: class {}, Date, URL, FormData, window: { confirm: () => true }, console })
vm.runInContext(code, context)
const c = new context.Calendar()
let selected = 'available'
const fields = { area_name: { value: 'Bordeaux' }, travel_radius_km: { value: '50' }, from: { value: '2026-10-08' }, to: { value: '2026-10-31' } }
c.element = { reportValidity: () => true, elements: fields, dataset: {}, querySelector: () => ({ value: selected }), querySelectorAll: () => [{ value: '5' }, { value: '6' }] }
c.feedbackTarget = { textContent: '' }; c.modeTarget = { textContent: '', classList: { toggle() {} } }
c.activateTarget = {}; c.periodTarget = {}; c.undoTarget = { hidden: true }
const day = { value: '2026-10-16', dataset: { past: 'false' }, setAttribute(name, value) { this[name] = value } }
c.dayTargets = [day, { dataset: { past: 'true' } }]
c.connect(); assert(day.disabled); assert.match(c.modeTarget.textContent, /Consultation/)
c.active = true; c.refresh(); assert(!day.disabled); assert(c.dayTargets[1].disabled)
assert.equal(c.periodDates().length, 8); assert.match(c.periodTarget.textContent, /8 dates/)
c.parametersChanged(); assert(!c.active); assert(day.disabled)
c.active = true; c.body = () => new FormData(); c.request = async () => ({ undo_token: 'signed' })
await c.paint({ preventDefault() {}, currentTarget: day }); assert.equal(day.dataset.state, 'available'); assert(!c.undoTarget.hidden); assert.match(c.feedbackTarget.textContent, /enregistré/)
c.request = async () => { throw new Error('Échec réseau') }; selected = 'unavailable'
await c.paint({ preventDefault() {}, currentTarget: day }); assert.equal(day.dataset.state, 'available'); assert.equal(c.feedbackTarget.textContent, 'Échec réseau'); assert(!c.busy)
c.request = async () => ({ state: 'on_request' }); await c.undo(); assert.equal(day.dataset.state, 'on_request'); assert(c.undoTarget.hidden)
c.active = true; c.request = async () => ({ ok: true }); selected = 'available'; await c.period({ preventDefault() {} });
assert.match(c.feedbackTarget.textContent, /8 dates enregistrées/); assert.equal(day.dataset.state, 'available')
c.finish(); assert(day.disabled); assert(!c.active)
console.log('Calendrier : consultation, activation, pause, période, réussite, échec, annulation et fin vérifiés.')
