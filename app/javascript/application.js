import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import "chartkick"
import "Chart.bundle"

// Register SW (only in production or whenever you like)
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .catch((err) => console.error('SW registration failed:', err));
  });
}
