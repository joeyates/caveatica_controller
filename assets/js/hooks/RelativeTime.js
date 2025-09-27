import {ViewHook} from '../../../deps/phoenix_live_view'

class RelativeTime extends ViewHook {
  mounted() {
    if (!this.el) {
      throw new Error('RelativeTime: element not found')
    }
    this.timer = window.setInterval(() => this.show(), 500)
    this.target = document.getElementById(this.el.dataset.targetId)
    if (!this.target) {
      throw new Error('RelativeTime: target element not found')
    }
    this.show()
  }

  show() {
    const datetime = this.el.dataset.datetime
    if (!datetime) {
      this.setValue('none')
      return
    }
    const date = new Date(datetime)
    const difference = Date.now() - date
    const seconds = Math.round(difference / 1000)
    const plural = seconds !== 1 ? 's' : ''
    this.setValue(`${seconds} second${plural} ago`)
  }

  setValue(value) {
    this.target.innerHTML = value
  }
}

export default RelativeTime

