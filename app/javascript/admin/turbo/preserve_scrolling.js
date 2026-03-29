// https://www.konnorrogers.com/posts/2023/maintain-scroll-position-in-turbo-without-data-turbo-permanent
// https://github.com/hotwired/turbo/pull/1040

if (!window.scrollPositions) {
  window.scrollPositions = {};
}

function preserveScroll () {
  document.querySelectorAll("[data-preserve-scroll]").forEach((element) => {
    scrollPositions[element.id] = element.scrollTop;
  })
}

function restoreScroll (event) {
  document.querySelectorAll("[data-preserve-scroll]").forEach((element) => {
    element.scrollTop = scrollPositions[element.id];
  })

  if (!event.detail.newBody) return
  // event.detail.newBody is the body element to be swapped in.
  // https://turbo.hotwired.dev/reference/events
  event.detail.newBody.querySelectorAll("[data-preserve-scroll]").forEach((element) => {
    element.scrollTop = scrollPositions[element.id];
  })
}

window.addEventListener("turbo:before-cache", preserveScroll)
window.addEventListener("turbo:before-render", restoreScroll)
window.addEventListener("turbo:render", restoreScroll)
