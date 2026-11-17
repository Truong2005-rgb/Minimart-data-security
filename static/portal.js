/* No remote dependencies. Menu icons, sidebar and revenue charts are local. */
(() => {
  'use strict';
  const paths = {
    'layout-dashboard':'<rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/>',
    'receipt-text':'<path d="M4 3h16v18l-4-2-4 2-4-2-4 2z"/><path d="M8 8h8M8 12h8M8 16h5"/>',
    'chart-no-axes-combined':'<path d="M3 20h18M4 14l4-4 5 3 6-8M16 5h3v3"/><path d="M6 20v-4M11 20v-5M16 20v-8"/>',
    'chart-column-increasing':'<path d="M4 20h16M5 16h3v4H5zM11 11h3v9h-3zM17 5h3v15h-3z"/>',
    'wallet':'<rect x="3" y="5" width="18" height="15" rx="3"/><path d="M3 9h18M16 14h2"/>',
    'package':'<path d="M12 2 21 7v10l-9 5-9-5V7zM3 7l9 5 9-5M12 12v10M7 5l9 5"/>',
    'users':'<circle cx="9" cy="8" r="3"/><path d="M3 20v-2a6 6 0 0 1 12 0v2M17 4a3 3 0 0 1 0 6M17 14a5 5 0 0 1 4 5"/>',
    'user-round':'<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
    'settings-2':'<path d="M4 7h16M4 17h16"/><circle cx="8" cy="7" r="2"/><circle cx="16" cy="17" r="2"/>',
    'shield-check':'<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/>',
    'shield-alert':'<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M12 8v5m0 4h.01"/>',
    'arrow-up-right':'<path d="M6 18 18 6M8 6h10v10"/>',
    'calendar-days':'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 10h18M8 14h3M14 14h3"/>',
    'sliders-horizontal':'<path d="M4 7h16M4 17h16"/><circle cx="9" cy="7" r="2"/><circle cx="15" cy="17" r="2"/>',
    'search':'<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
    'menu':'<path d="M4 6h16M4 12h16M4 18h16"/>',
    'log-out':'<path d="M9 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h4M16 17l5-5-5-5M21 12H9"/>'
  };
  document.querySelectorAll('[data-icon]').forEach(el => {
    const content=paths[el.dataset.icon];
    if (!content) return;
    el.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'+content+'</svg>';
  });
  const sidebar=document.querySelector('.sidebar');
  const shade=document.querySelector('.sidebar-shade');
  document.querySelector('[data-toggle-sidebar]')?.addEventListener('click',()=>{sidebar.classList.add('open');shade.classList.add('show')});
  document.querySelector('[data-close-sidebar]')?.addEventListener('click',()=>{sidebar.classList.remove('open');shade.classList.remove('show')});
  document.querySelectorAll('.nav-item').forEach(e=>e.addEventListener('click',()=>shade?.classList.remove('show')));

  function plot(card){
    const canvas=card.querySelector('canvas.revenue-chart');
    const json=card.querySelector('.chart-data');
    if (!canvas || !json)return;
    let series;
    try{series=JSON.parse(json.textContent)}catch{return}
    const ctx=canvas.getContext('2d');
    if(!ctx)return;
    const draw=()=>{
      const rect=canvas.getBoundingClientRect();
      if(rect.width<30 || rect.height<30)return;
      const ratio=Math.min(window.devicePixelRatio||1,2);canvas.width=Math.round(rect.width*ratio);canvas.height=Math.round(rect.height*ratio);
      ctx.setTransform(ratio,0,0,ratio,0,0);
      const w=rect.width,h=rect.height,l=49,r=14,t=12,b=27;const pw=w-l-r,ph=h-t-b;
      const vals=series.map(x=>Number(x.revenue)||0),max=Math.max(1,...vals)*1.13;
      ctx.font='10px Segoe UI, system-ui, sans-serif';ctx.lineWidth=1;ctx.textBaseline='middle';
      for(let i=0;i<5;i++){
        let yy=t+ph*i/4;ctx.strokeStyle='#edf1f6';ctx.beginPath();ctx.moveTo(l,yy);ctx.lineTo(w-r,yy);ctx.stroke();
        ctx.fillStyle='#97a4b7';ctx.textAlign='right';let value=max*(4-i)/4;ctx.fillText((value>=1e6?(value/1e6).toFixed(1)+'M':value>=1e3?Math.round(value/1e3)+'K':String(Math.round(value))),l-7,yy);
      }
      if(!series.length)return;
      const pos=i=>[l+(vals.length===1?pw/2:(i/(vals.length-1))*pw),t+ph*(1-vals[i]/max)];
      const grad=ctx.createLinearGradient(0,t,0,h-b);grad.addColorStop(0,'rgba(35,167,191,.23)');grad.addColorStop(1,'rgba(35,167,191,0)');
      ctx.beginPath();let [x0,y0]=pos(0);ctx.moveTo(x0,h-b);ctx.lineTo(x0,y0);
      for(let i=1;i<vals.length;i++){let [x,y]=pos(i);ctx.lineTo(x,y)}ctx.lineTo(pos(vals.length-1)[0],h-b);ctx.closePath();ctx.fillStyle=grad;ctx.fill();
      ctx.beginPath();for(let i=0;i<vals.length;i++){let [x,y]=pos(i);i?ctx.lineTo(x,y):ctx.moveTo(x,y)}ctx.strokeStyle='#1fa79f';ctx.lineWidth=2.8;ctx.lineJoin='round';ctx.stroke();
      if(vals.length<=18){for(let i=0;i<vals.length;i++){const [x,y]=pos(i);ctx.beginPath();ctx.arc(x,y,2.7,0,Math.PI*2);ctx.fillStyle='#fff';ctx.fill();ctx.strokeStyle='#16aa9f';ctx.stroke()}}
      ctx.fillStyle='#8795ad';ctx.font='10px Segoe UI, system-ui, sans-serif';ctx.textAlign='center';ctx.textBaseline='top';
      const stride=Math.max(1,Math.ceil(series.length/7));
      for(let i=0;i<series.length;i+=stride){const [x]=pos(i);ctx.fillText(series[i].label.slice(0,5),x,h-b+8)}
    };
    draw();window.addEventListener('resize',draw,{passive:true});
  }
  document.querySelectorAll('.chart-panel').forEach(plot);
})();
