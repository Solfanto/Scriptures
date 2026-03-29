// Entry point for the admin JavaScript
import '@hotwired/turbo-rails'
import 'admin/controllers'
import 'admin/turbo'

// Prevent prefetching on slow internet or when saving data
document.addEventListener('turbo:before-prefetch', (event) => {
  if (isSavingData() || hasSlowInternet()) {
    event.preventDefault()
  }
})

function isSavingData () {
  return navigator.connection?.saveData
}

function hasSlowInternet () {
  return navigator.connection?.effectiveType === 'slow-2g' ||
         navigator.connection?.effectiveType === '2g'
}
