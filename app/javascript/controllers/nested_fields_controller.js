import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['template', 'container'];

  connect() {}

  add(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    this.containerTarget.insertAdjacentHTML('beforeend', content);

    const nestedItems = this.containerTarget.querySelectorAll('[data-new-field]');
    const newField = nestedItems[nestedItems.length - 1];
    const newPosition = nestedItems.length;

    const positionInput = newField.querySelector("input[name*='position']");
    if (positionInput) {
      positionInput.value = newPosition;
    }
  }

  remove(event) {
    event.preventDefault();
    const field = event.currentTarget.closest('[data-new-field]');
    if (field) {
      field.remove();
    }
  }
}
