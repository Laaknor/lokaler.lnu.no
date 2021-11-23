import { Controller } from "@hotwired/stimulus"
import Splide from '@splidejs/splide';

// Connects to data-controller="slider"
export default class extends Controller {
  static targets = [ "slider", "toggleFullscreen" ]

  connect() {
    const slider = this.sliderTarget
    new Splide(slider, {
      heightRatio: 2/3,
      cover: true,
      i18n: {
        prev: 'Forrige',
        next: 'Neste',
        first: 'Første',
        last: 'Siste',
        slideX: 'Gå til %s',
        pageX: 'Side %s'
      }
    }).mount()
  }
  disconnect() {
    super.disconnect();
  }
}
