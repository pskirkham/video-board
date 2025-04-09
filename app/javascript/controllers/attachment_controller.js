import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  toggle() {
    const input = this.element;
    const nestedField = input.closest('.nested-field');
    const durationField = nestedField.querySelector('#duration-field');

    if (input.files && input.files.length > 0) {
      if (input.files[0].type.startsWith('image/')) {
        durationField.classList.remove('hidden');
      } else {
        durationField.classList.add('hidden');
      }
    } else {
      durationField.classList.add('hidden');
    }
  }
}
