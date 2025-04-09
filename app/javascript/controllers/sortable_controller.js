import { Controller } from '@hotwired/stimulus';
import Sortable from 'sortablejs';

export default class extends Controller {
  static targets = ['container'];

  connect() {
    this.sortable = Sortable.create(this.containerTarget, {
      handle: '.drag-handle',
      animation: 150,
      onStart: this.onStart.bind(this),
      onEnd: this.onEnd.bind(this),
    });
  }

  onStart(evt) {
    evt.item.style.visibility = 'hidden';
  }

  onEnd(evt) {
    evt.item.style.visibility = '';
    this.reorder();
  }

  reorder() {
    const items = this.containerTarget.querySelectorAll('.nested-field');
    items.forEach((item, index) => {
      const input = item.querySelector("input[type='hidden'][name*='position']");
      if (input) {
        input.value = index + 1;
      }
    });
  }
}
