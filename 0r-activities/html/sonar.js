(() => {
    'use strict';
    const panel = document.createElement('section');
    panel.className = 'diving-sonar'; panel.hidden = true;
    panel.setAttribute('data-i18n-aria-label', 'diving_sonar');
    panel.innerHTML = `<div class="sonar-display"><canvas width="520" height="520"></canvas></div>
      <div class="sonar-readings"><div><small data-i18n="depth"></small><b data-field="depth">0.0</b><em>m</em></div><div><small data-i18n="range"></small><b data-field="range">80</b><em>m</em></div><div><small data-i18n="compass"></small><b data-field="heading">000</b><em>°</em></div></div>`;
    document.body.append(panel);
    const fields = Object.fromEntries([...panel.querySelectorAll('[data-field]')].map(node => [node.dataset.field, node]));
    const set = (key, value) => { const text = String(value); if (fields[key].textContent !== text) fields[key].textContent = text; };
    const canvas = panel.querySelector('canvas'), ctx = canvas.getContext('2d');
    const grid = document.createElement('canvas'); grid.width = grid.height = 520;
    const g = grid.getContext('2d'), C = 260, R = 225, TAU = Math.PI * 2;
    const norm = a => (a % TAU + TAU) % TAU;
    let state = null, received = 0, timer = null, sweep = 0, last = 0, gridRange = null, audio = null, lastPing = 0;
    const echoes = new Map();
    function buildGrid(range) {
        gridRange = range; g.clearRect(0, 0, 520, 520);
        g.lineWidth = 1; g.strokeStyle = '#ffffff40';
        for (let ring = 1; ring <= 4; ring++) { g.beginPath(); g.arc(C,C,R*ring/4,0,TAU); g.stroke(); }
        for (let deg=0; deg<360; deg+=5) {
            const a=deg*Math.PI/180, outer=R+(deg%30===0?11:5);
            g.strokeStyle=deg%30===0?'#ffffff99':'#ffffff55';
            g.beginPath();g.moveTo(C+Math.sin(a)*R,C-Math.cos(a)*R);g.lineTo(C+Math.sin(a)*outer,C-Math.cos(a)*outer);g.stroke();
        }
        g.strokeStyle='#ffffff26';g.beginPath();g.moveTo(C-R,C);g.lineTo(C+R,C);g.moveTo(C,C-R);g.lineTo(C,C+R);g.stroke();
        g.font='700 14px "Plus Jakarta Sans", sans-serif';g.fillStyle='#ffffff90';g.textAlign='left';
        for(let i=1;i<=4;i++)g.fillText(`${Math.round(range*i/4)}`,C+5,C-R*i/4+16);

    }
    function hide() {
        panel.hidden=true;state=null;echoes.clear();last=0;sweep=0;
        if(timer!==null)clearInterval(timer);timer=null;
        if(audio?.state==='running')audio.suspend().catch(()=>{});
    }
    function ping(strength) {
        const now=performance.now(); if(now-lastPing<650)return; lastPing=now;
        try {
            const Audio=window.AudioContext||window.webkitAudioContext;if(!Audio)return;
            audio=audio||new Audio();if(audio.state==='suspended')audio.resume().catch(()=>{});
            if(audio.state!=='running')return;
            const osc=audio.createOscillator(), gain=audio.createGain(), t=audio.currentTime;
            osc.type='sine';osc.frequency.setValueAtTime(1150+strength*550,t);osc.frequency.exponentialRampToValueAtTime(800,t+.14);
            gain.gain.setValueAtTime(.0001,t);gain.gain.exponentialRampToValueAtTime(.014+strength*.016,t+.008);gain.gain.exponentialRampToValueAtTime(.0001,t+.28);
            osc.connect(gain);gain.connect(audio.destination);osc.start(t);osc.stop(t+.3);
            osc.onended=()=>{osc.disconnect();gain.disconnect();};
        } catch (_) {  }
    }
    function render() {
        if(!state||panel.hidden)return;
        const now=performance.now();if(now-received>2000){hide();return;}
        const dt=Math.min(150,last?now-last:50);last=now;
        const step=TAU*dt/state.sweepMilliseconds;
        if(state.underwater)sweep=norm(sweep+step);
        ctx.clearRect(0,0,520,520);
        ctx.drawImage(grid,0,0);
        ctx.save();ctx.beginPath();ctx.arc(C,C,R,0,TAU);ctx.clip();
        if(state.underwater){
            for(let i=24;i>=0;i--){const a=sweep-i*.016;ctx.strokeStyle=`rgba(245,245,243,${.008+(24-i)*.0018})`;ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(C,C);ctx.lineTo(C+Math.sin(a)*R,C-Math.cos(a)*R);ctx.stroke();}
            ctx.strokeStyle='#f5f5f3bb';ctx.lineWidth=1.2;ctx.beginPath();ctx.moveTo(C,C);ctx.lineTo(C+Math.sin(sweep)*R,C-Math.cos(sweep)*R);ctx.stroke();
        }
        for(const point of state.contacts){
            const dx=point.x-state.x,dy=point.y-state.y,distance=Math.hypot(dx,dy);if(distance>state.range)continue;
            const angle=norm(Math.atan2(dx,dy)+state.heading*Math.PI/180);
            if(state.underwater&&norm(sweep-angle)<=step+.025){
                const previous=echoes.get(point.id);
                if(!previous||now-previous.at>state.sweepMilliseconds*.65){echoes.set(point.id,{at:now});ping(1-distance/state.range);}
            }
            const echo=echoes.get(point.id);if(!echo||!state.underwater)continue;
            const age=now-echo.at, life=state.sweepMilliseconds*1.25;if(age>life)continue;
            const alpha=Math.max(0,1-age/life),radius=distance/state.range*R,x=C+Math.sin(angle)*radius,y=C-Math.cos(angle)*radius;
            const bloom=ctx.createRadialGradient(x,y,0,x,y,12);bloom.addColorStop(0,`rgba(255,255,255,${alpha*.6})`);bloom.addColorStop(1,'rgba(245,245,243,0)');
            ctx.fillStyle=bloom;ctx.fillRect(x-12,y-12,24,24);ctx.fillStyle=`rgba(255,255,255,${alpha})`;
            ctx.beginPath();ctx.ellipse(x,y,3.4,2.2,angle,0,TAU);ctx.fill();
        }
        ctx.restore();
        ctx.font='800 15px "Plus Jakarta Sans", sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillStyle='#ffffffbb';
        ['N','E','S','W'].forEach((label,i)=>{const a=i*Math.PI/2+state.heading*Math.PI/180;ctx.fillText(label,C+Math.sin(a)*248,C-Math.cos(a)*248);});
        ctx.fillStyle='#f5f5f3';ctx.beginPath();ctx.moveTo(C,C-8);ctx.lineTo(C-5,C+5);ctx.lineTo(C+5,C+5);ctx.closePath();ctx.fill();
    }
    window.addEventListener('message',({data:message})=>{
        if(message?.action==='diving:sonar:hide'){hide();return;}
        if(message?.action!=='diving:sonar')return;
        const data=message.data;
        if(!data||![data.x,data.y,data.z,data.heading,data.depth,data.range,data.sweepMilliseconds].every(Number.isFinite)||data.range<=0||!Array.isArray(data.contacts))return;
        if(state&&state.session!==data.session)hide();
        state={...data,sweepMilliseconds:Math.max(1500,data.sweepMilliseconds),contacts:data.contacts.filter(p=>p&&[p.x,p.y,p.z].every(Number.isFinite))};received=performance.now();
        const ids=new Set(state.contacts.map(p=>p.id));for(const id of echoes.keys())if(!ids.has(id))echoes.delete(id);
        if(!data.underwater)echoes.clear();
        panel.hidden=false;panel.classList.toggle('standby',!data.underwater);
        set('depth',data.depth.toFixed(1));set('range',Math.round(data.range));set('heading',String(Math.round((360-data.heading)%360+360)%360).padStart(3,'0'));
        if(gridRange!==data.range)buildGrid(data.range);
        if(timer===null){render();timer=setInterval(render,50);}
    });
    window.addEventListener('pagehide',hide);
})();
