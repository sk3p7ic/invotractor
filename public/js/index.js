function sumHourly() {
  const total = Array.from(document.querySelectorAll('#hours-table > div.table-row > *:last-child'))
    .map(e => Number(e.innerHTML.substring(1)))
    .reduce((a, t) => a + t, 0);
  document.querySelector('#hours-table .table-footer p').innerHTML = `\$${total.toFixed(2)}`;
}

const observer = new MutationObserver(muts => {
  muts.forEach(m => {
    if (m.type === 'childList' && m.addedNodes.length > 0) {
      m.addedNodes.forEach(n => {
        if (n.nodeType === 1 && n.tagName.toLowerCase() === 'div') {
          sumHourly();
        }
      });
    }
  });
});

observer.observe(document.querySelector('#hours-table'), { childList: true });