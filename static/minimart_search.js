/* MINIMART_SEARCH_V1: instant filter on already-loaded product rows only. */
(() => {
  'use strict';
  const norm = s => String(s || '').normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[đĐ]/g, 'd').toLowerCase().trim();
  document.querySelectorAll('input[data-mm-filter]').forEach(input => {
    const table = document.getElementById(input.dataset.mmFilter);
    const tbody = table?.tBodies?.[0];
    if (!tbody) return;
    const rows = [...tbody.rows].filter(r => !r.querySelector('td.empty'));
    const count = document.querySelector('[data-mm-count="' + input.dataset.mmFilter + '"]');
    if (rows.length === 0) return;
    const empty = document.createElement('tr');
    const cell = document.createElement('td');
    cell.colSpan = table.tHead?.rows?.[0]?.cells?.length || rows[0].cells.length;
    cell.className = 'empty';
    cell.textContent = 'Không tìm thấy kết quả phù hợp.';
    empty.appendChild(cell);
    empty.style.display = 'none';
    tbody.appendChild(empty);
    const apply = () => {
      const query = norm(input.value);
      let shown = 0;
      rows.forEach(row => {
        const matched = !query || norm(row.textContent).includes(query);
        row.style.display = matched ? '' : 'none';
        if (matched) shown++;
      });
      empty.style.display = shown === 0 ? '' : 'none';
      if (count) count.textContent = shown + '/' + rows.length + ' dòng';
    };
    input.addEventListener('input', apply);
    apply();
  });
})();
