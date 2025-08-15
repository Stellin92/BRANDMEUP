import { Controller } from "@hotwired/stimulus"

// Stimulus controller qui gère reveal + parallax
export default class extends Controller {
  static targets = ["section", "image"]

  connect() {
    this.handleScroll = this.parallax.bind(this)

    // Intersection Observer pour les reveals
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible")
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.2 })

    this.sectionTargets.forEach(section => {
      observer.observe(section)
    })

    // écoute du scroll pour le parallax
    window.addEventListener("scroll", this.handleScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  parallax() {
    const scrollY = window.scrollY
    this.imageTargets.forEach(imgWrapper => {
      const rect = imgWrapper.getBoundingClientRect()
      const offset = rect.top * 0.1 // intensité du parallax (0.1 = léger)
      const img = imgWrapper.querySelector("img")
      if (img) {
        img.style.transform = `translateY(${offset}px)`
      }
    })
  }
}
