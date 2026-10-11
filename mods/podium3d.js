/* HviK Link – Siegerpodium als Minecraft-Szene (three.js r128, global THREE).
 * hvikPodium(container, players, opts)
 *   players: [{name, uuid, value, place}] sortiert (Platz 1 zuerst)
 *   opts: {title, subtitle, instant}  - instant = ohne Aufdeck-Animation (z. B. Archiv)
 * Blöcke mit selbst erzeugten Pixel-Texturen im Minecraft-Stil; Skins von mc-heads.net.
 */
(function(){
  const B = 16;  // 1 Block = 16 Einheiten, Spieler = 32 hoch (wie in Minecraft)

  // ---------- Pixel-Texturen ----------
  function rnd(seed){ let s = seed >>> 0; return () => ((s = (s * 1664525 + 1013904223) >>> 0) / 4294967296); }
  function tex(draw, seed){
    const c = document.createElement('canvas'); c.width = c.height = 16;
    const g = c.getContext('2d'), r = rnd(seed || 7);
    draw(g, r);
    const t = new THREE.CanvasTexture(c);
    t.magFilter = THREE.NearestFilter; t.minFilter = THREE.NearestFilter;
    return t;
  }
  const noise = (base, spread) => (g, r) => {
    for (let x = 0; x < 16; x++) for (let y = 0; y < 16; y++) {
      const k = (r() - 0.5) * spread;
      g.fillStyle = `rgb(${base[0] + k},${base[1] + k},${base[2] + k})`; g.fillRect(x, y, 1, 1);
    }
  };
  const T = {};
  function textures(){
    T.grassTop = tex(noise([95, 159, 53], 34), 1);
    T.dirt = tex(noise([134, 96, 67], 30), 2);
    T.grassSide = tex((g, r) => { noise([134, 96, 67], 30)(g, r);
      for (let x = 0; x < 16; x++) { const d = 3 + Math.floor(r() * 2.5); for (let y = 0; y < d; y++) { const k = (r() - .5) * 30; g.fillStyle = `rgb(${95 + k},${159 + k},${53 + k})`; g.fillRect(x, y, 1, 1); } } }, 3);
    T.stone = tex(noise([125, 125, 125], 34), 4);
    T.snow = tex(noise([240, 246, 250], 14), 5);
    T.snowSide = tex((g, r) => { noise([125, 125, 125], 34)(g, r); for (let x = 0; x < 16; x++) { const d = 2 + Math.floor(r() * 3); g.fillStyle = '#eef3f6'; g.fillRect(x, 0, 1, d); } }, 6);
    T.logSide = tex((g, r) => { for (let x = 0; x < 16; x++) for (let y = 0; y < 16; y++) { const k = (x % 4 === 0 ? -22 : 0) + (r() - .5) * 18; g.fillStyle = `rgb(${102 + k},${81 + k},${51 + k})`; g.fillRect(x, y, 1, 1); } }, 8);
    T.logTop = tex((g, r) => { noise([160, 130, 80], 18)(g, r); g.strokeStyle = '#7a5f38'; g.strokeRect(2.5, 2.5, 11, 11); g.strokeRect(5.5, 5.5, 5, 5); }, 9);
    T.leaves = tex((g, r) => { for (let x = 0; x < 16; x++) for (let y = 0; y < 16; y++) { const k = (r() - .5) * 60; g.fillStyle = r() < .12 ? 'rgb(30,70,25)' : `rgb(${58 + k / 2},${120 + k},${40 + k / 2})`; g.fillRect(x, y, 1, 1); } }, 10);
    const metal = (c1, c2, c3, seed) => tex((g, r) => { noise(c1, 16)(g, r); g.fillStyle = c2; g.fillRect(0, 0, 16, 1); g.fillRect(0, 0, 1, 16);
      g.fillStyle = c3; g.fillRect(0, 15, 16, 1); g.fillRect(15, 0, 1, 16); g.fillStyle = 'rgba(255,255,255,.35)'; g.fillRect(2, 2, 4, 1); g.fillRect(2, 2, 1, 4); }, seed);
    T.gold = metal([246, 208, 61], '#fff3a8', '#b88a10', 11);
    T.iron = metal([220, 220, 220], '#ffffff', '#9a9a9a', 12);
    T.copper = metal([200, 116, 72], '#f0a777', '#8a4a28', 13);
    T.cloud = tex(noise([255, 255, 255], 4), 14);
  }
  const mat = t => new THREE.MeshLambertMaterial({map: t});
  // Reihenfolge der BoxGeometry-Seiten: +x, -x, +y (oben), -y (unten), +z, -z
  function blockMats(kind){
    switch (kind) {
      case 'grass': return [mat(T.grassSide), mat(T.grassSide), mat(T.grassTop), mat(T.dirt), mat(T.grassSide), mat(T.grassSide)];
      case 'snow': return [mat(T.snowSide), mat(T.snowSide), mat(T.snow), mat(T.stone), mat(T.snowSide), mat(T.snowSide)];
      case 'log': return [mat(T.logSide), mat(T.logSide), mat(T.logTop), mat(T.logTop), mat(T.logSide), mat(T.logSide)];
      case 'leaves': { const m = mat(T.leaves); return m; }
      case 'cloud': return new THREE.MeshLambertMaterial({map: T.cloud, transparent: true, opacity: .9});
      default: return mat(T[kind]);
    }
  }

  // ---------- Welt ----------
  function world(scene){
    const blocks = {};
    const put = (kind, x, y, z) => (blocks[kind] = blocks[kind] || []).push([x, y, z]);
    // Wiese vorne
    for (let x = -22; x <= 22; x++) for (let z = -3; z <= 22; z++) put('grass', x, -1, z);
    // Berge hinten (Höhenkarte)
    const h = (x, z) => {
      const m1 = 13 * Math.exp(-(((x - 6) / 7) ** 2 + ((z + 13) / 4) ** 2));
      const m2 = 8 * Math.exp(-(((x + 11) / 6) ** 2 + ((z + 11) / 3.5) ** 2));
      const m3 = 5 * Math.exp(-(((x - 17) / 5) ** 2 + ((z + 9) / 3) ** 2));
      return Math.round(m1 + m2 + m3 + 1.2 * Math.sin(x * .7) * Math.cos(z * .9));
    };
    for (let x = -24; x <= 26; x++) for (let z = -18; z <= -4; z++) {
      const top = Math.max(0, h(x, z));
      for (let y = -1; y <= top - 1; y++) {
        const isTop = y === top - 1;
        put(isTop ? (top > 9 ? 'snow' : top > 5 ? 'stone' : 'grass') : (y > top - 4 && top <= 5 ? 'dirt' : 'stone'), x, y, z);
      }
      if (top <= 0) put('grass', x, -1, z);
    }
    // Bäume
    for (const [tx, tz] of [[-12, -4], [12, -4], [-16, -1], [16, 0], [-8, -5], [7, -6]]) {
      for (let y = 0; y < 4; y++) put('log', tx, y, tz);
      for (let dx = -2; dx <= 2; dx++) for (let dz = -2; dz <= 2; dz++) for (let dy = 3; dy <= 4; dy++) if (Math.abs(dx) + Math.abs(dz) < 4) put('leaves', tx + dx, dy, tz + dz);
      for (let dx = -1; dx <= 1; dx++) for (let dz = -1; dz <= 1; dz++) put('leaves', tx + dx, 5, tz + dz);
    }
    // Wolken
    for (const [cx, cz, w, d] of [[-14, -14, 6, 3], [4, -20, 8, 4], [18, -12, 5, 3]]) for (let x = 0; x < w; x++) for (let z = 0; z < d; z++) put('cloud', cx + x, 15, cz + z);
    // Podium: Gold (1.) 3 hoch, Eisen (2.) 2 hoch links, Kupfer (3.) 1 hoch rechts
    for (let y = 0; y < 3; y++) put('gold', 0, y, 0);
    for (let y = 0; y < 2; y++) put('iron', -1, y, 0);
    put('copper', 1, 0, 0);
    const geo = new THREE.BoxGeometry(B, B, B);
    const m4 = new THREE.Matrix4();
    for (const [kind, list] of Object.entries(blocks)) {
      const mesh = new THREE.InstancedMesh(geo, blockMats(kind), list.length);
      list.forEach(([x, y, z], i) => { m4.makeTranslation(x * B, y * B + B / 2, z * B); mesh.setMatrixAt(i, m4); });
      scene.add(mesh);
    }
  }

  // ---------- Spielerfigur aus dem Skin ----------
  function faceUV(geo, face, rect, W, H, flipX){
    const [x0, y0, x1, y1] = rect, uv = geo.attributes.uv;
    const a = flipX ? [x1, x0] : [x0, x1];
    const pts = [[a[0], y0], [a[1], y0], [a[0], y1], [a[1], y1]];
    pts.forEach(([u, v], i) => uv.setXY(face * 4 + i, u / W, 1 - v / H));
  }
  // w,h,d in Skin-Pixeln, (u,v) = Ecke im Skin
  function part(w, h, d, u, v, texture, grow, W, H, mirror){
    const geo = new THREE.BoxGeometry(w + grow, h + grow, d + grow);
    const R = (x, y, ww, hh) => [x, y, x + ww, y + hh];
    // +x = linke Seite der Figur (schaut nach +z), -x = rechte Seite
    faceUV(geo, mirror ? 1 : 0, R(u + d + w, v + d, d, h), W, H, mirror);
    faceUV(geo, mirror ? 0 : 1, R(u, v + d, d, h), W, H, mirror);
    faceUV(geo, 2, R(u + d, v, w, d), W, H, mirror);
    faceUV(geo, 3, R(u + d + w, v, w, d), W, H, mirror);
    faceUV(geo, 4, R(u + d, v + d, w, h), W, H, mirror);
    faceUV(geo, 5, R(u + d + w + d, v + d, w, h), W, H, !mirror);
    const m = new THREE.MeshLambertMaterial({map: texture, transparent: grow > 0, alphaTest: 0.05, side: grow > 0 ? THREE.DoubleSide : THREE.FrontSide});
    return new THREE.Mesh(geo, m);
  }
  function player(img){
    const W = 64, H = img.height >= 64 ? 64 : 32, modern = H === 64;
    const c = document.createElement('canvas'); c.width = W; c.height = H; c.getContext('2d').drawImage(img, 0, 0);
    const ctx = c.getContext('2d');
    const slim = modern && ctx.getImageData(54, 20, 1, 1).data[3] === 0;
    const hat = ctx.getImageData(32, 0, 32, 16).data;
    let hatClear = false;  // Minecraft blendet eine komplett deckende Hut-Ebene aus (alte Skins haben dort oft Schwarz)
    for (let i = 3; i < hat.length; i += 4) if (hat[i] < 128) { hatClear = true; break; }
    const t = new THREE.CanvasTexture(c); t.magFilter = THREE.NearestFilter; t.minFilter = THREE.NearestFilter;
    const aw = slim ? 3 : 4;
    const grp = new THREE.Group();
    const add = (parent, mesh, x, y, z) => { mesh.position.set(x, y, z); parent.add(mesh); return mesh; };
    const joint = (x, y, z) => { const j = new THREE.Group(); j.position.set(x, y, z); grp.add(j); return j; };
    // Kopf
    const head = joint(0, 24, 0);
    add(head, part(8, 8, 8, 0, 0, t, 0, W, H), 0, 4, 0);
    if (hatClear) add(head, part(8, 8, 8, 32, 0, t, 1, W, H), 0, 4, 0);
    // Körper
    add(grp, part(8, 12, 4, 16, 16, t, 0, W, H), 0, 18, 0);
    if (modern) add(grp, part(8, 12, 4, 16, 32, t, .5, W, H), 0, 18, 0);
    // Arme (Gelenk an der Schulter)
    const rArm = joint(-(4 + aw / 2), 22, 0), lArm = joint(4 + aw / 2, 22, 0);
    add(rArm, part(aw, 12, 4, 40, 16, t, 0, W, H), 0, -4, 0);
    if (modern) { add(rArm, part(aw, 12, 4, 40, 32, t, .5, W, H), 0, -4, 0); add(lArm, part(aw, 12, 4, 32, 48, t, 0, W, H), 0, -4, 0); add(lArm, part(aw, 12, 4, 48, 48, t, .5, W, H), 0, -4, 0); }
    else add(lArm, part(aw, 12, 4, 40, 16, t, 0, W, H, true), 0, -4, 0);
    // Beine (Gelenk an der Hüfte)
    const rLeg = joint(-2, 12, 0), lLeg = joint(2, 12, 0);
    add(rLeg, part(4, 12, 4, 0, 16, t, 0, W, H), 0, -6, 0);
    if (modern) { add(rLeg, part(4, 12, 4, 0, 32, t, .5, W, H), 0, -6, 0); add(lLeg, part(4, 12, 4, 16, 48, t, 0, W, H), 0, -6, 0); add(lLeg, part(4, 12, 4, 0, 48, t, .5, W, H), 0, -6, 0); }
    else add(lLeg, part(4, 12, 4, 0, 16, t, 0, W, H, true), 0, -6, 0);
    grp.userData = {head, rArm, lArm, rLeg, lLeg};
    return grp;
  }
  function pose(p, kind){
    const {head, rArm, lArm, rLeg, lLeg} = p.userData;
    if (kind === 'sit') {  // im Schneidersitz-artig: Beine nach vorne, etwas tiefer
      rLeg.rotation.x = lLeg.rotation.x = -Math.PI / 2;
      rLeg.rotation.y = .18; lLeg.rotation.y = -.18;
      rArm.rotation.x = lArm.rotation.x = -.5;
      p.userData.drop = 11;
    } else if (kind === 'win') {  // Sieger: Arme hoch
      rArm.rotation.z = -2.7; lArm.rotation.z = 2.7;
      head.rotation.x = -.15;
    } else if (kind === 'cheer') {
      rArm.rotation.z = -2.5; rArm.rotation.x = -.2;
    } else {
      rArm.rotation.z = -.08; lArm.rotation.z = .08;
    }
  }
  function loadImg(src){
    return new Promise(res => { const i = new Image(); i.crossOrigin = 'anonymous'; i.onload = () => res(i); i.onerror = () => res(null); i.src = src; });
  }

  // ---------- Aufstellung ----------
  function spots(n){
    const out = [];
    out.push({x: 0, y: 3 * B, z: 0, pose: 'win'});          // 1.
    out.push({x: -B, y: 2 * B, z: 0, pose: 'cheer'});        // 2.
    out.push({x: B, y: B, z: 0, pose: 'stand'});             // 3.
    const side = [];                                         // neben dem Podium stehend
    for (let i = 0; i < 6; i++) side.push({x: (i % 2 ? 1 : -1) * (2.4 + Math.floor(i / 2) * 1.3) * B, y: 0, z: -Math.floor(i / 2) * 6, pose: 'stand'});
    const rest = n - 3;
    const standCount = Math.min(side.length, rest <= 4 ? rest : Math.min(6, Math.ceil(rest / 2)));
    out.push(...side.slice(0, standCount));
    const sitting = Math.max(0, rest - standCount);           // davor sitzend, Reihen à 7
    for (let i = 0; i < sitting; i++) {
      const row = Math.floor(i / 7), inRow = Math.min(7, sitting - row * 7), k = i % 7;
      out.push({x: (k - (inRow - 1) / 2) * 1.55 * B, y: 0, z: (2.4 + row * 1.7) * B, pose: 'sit'});
    }
    return out.slice(0, n);
  }

  window.hvikPodium = async function(box, players, opts = {}){
    box.classList.add('hvp');
    box.innerHTML = '';
    const Wd = box.clientWidth, Ht = box.clientHeight;
    const renderer = new THREE.WebGLRenderer({antialias: false, preserveDrawingBuffer: true});
    renderer.setPixelRatio(Math.min(2, window.devicePixelRatio || 1));
    renderer.setSize(Wd, Ht);
    box.appendChild(renderer.domElement);
    const labels = document.createElement('div'); labels.className = 'hvp-labels'; box.appendChild(labels);
    if (opts.title) {
      const t = document.createElement('div'); t.className = 'hvp-title';
      t.innerHTML = `<b></b><small></small>`; t.querySelector('b').textContent = opts.title; t.querySelector('small').textContent = opts.subtitle || '';
      box.appendChild(t);
    }
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x8ab8ff);
    scene.fog = new THREE.Fog(0x8ab8ff, 420, 900);
    scene.add(new THREE.AmbientLight(0xffffff, .62));
    const sun = new THREE.DirectionalLight(0xffffff, .55); sun.position.set(80, 160, 120); scene.add(sun);
    const back = new THREE.DirectionalLight(0xbcd0ff, .18); back.position.set(-100, 60, -80); scene.add(back);
    if (!T.grassTop) textures();
    world(scene);
    const cam = new THREE.PerspectiveCamera(34, Wd / Ht, 1, 1400);
    const n = players.length, many = n > 10, dist = many ? 300 : 260;
    cam.position.set(0, many ? 78 : 70, dist);
    const look = new THREE.Vector3(0, many ? 44 : 42, many ? 20 : 10);
    cam.lookAt(look);

    const sp = spots(n);
    const imgs = await Promise.all(players.map(p => loadImg(`https://mc-heads.net/skin/${encodeURIComponent(p.uuid || p.name || 'MHF_Steve')}`)));
    const fallback = await loadImg('https://mc-heads.net/skin/MHF_Steve');
    const figs = players.map((p, i) => {
      const img = imgs[i] || fallback;
      if (!img) return null;
      const f = player(img);
      const s = sp[i];
      pose(f, s.pose);
      f.position.set(s.x, s.y - (f.userData.drop || 0), s.z);
      f.rotation.y = Math.atan2(cam.position.x - s.x, cam.position.z - s.z) * .6;  // leicht zur Kamera drehen
      f.userData.base = f.position.y;
      f.visible = !!opts.instant;
      scene.add(f);
      const l = document.createElement('div');
      l.className = 'hvp-label' + (i < 3 ? ' top p' + (i + 1) : '') + (s.pose === 'sit' ? ' below' : '');
      l.innerHTML = `${i === 0 ? '<i>👑</i>' : ''}<b></b><span></span>`;
      l.querySelector('b').textContent = p.name;
      l.querySelector('span').textContent = `${i + 1}. · ${p.value}×`;
      l.style.opacity = opts.instant ? 1 : 0;
      labels.appendChild(l);
      return {f, l, i, sitting: s.pose === 'sit'};
    });

    // Aufdecken: vom letzten Platz nach vorne, die Top 3 zum Schluss mit Pause
    const order = figs.filter(Boolean).sort((a, b) => b.i - a.i);
    const start = performance.now();
    order.forEach((o, k) => {
      const top = o.i < 3;
      o.at = opts.instant ? -1 : (k - Math.max(0, order.length - 3)) >= 0
        ? (order.length - 3) * 450 + 900 + (2 - o.i) * 1300 : k * 450;
    });
    function place(){
      const v = new THREE.Vector3();
      figs.forEach(o => {
        if (!o) return;
        if (o.sitting) v.set(o.f.position.x, o.f.position.y + 8, o.f.position.z + 10).project(cam);  // Name unter die Sitzenden
        else v.set(o.f.position.x, o.f.position.y + 40, o.f.position.z).project(cam);
        o.l.style.left = ((v.x + 1) / 2 * Wd) + 'px';
        o.l.style.top = ((1 - v.y) / 2 * Ht) + 'px';
      });
    }
    function frame(now){
      const t = now - start;
      figs.forEach(o => {
        if (!o) return;
        if (o.at < 0) { o.f.visible = true; return; }
        const k = Math.min(1, Math.max(0, (t - o.at) / 500));
        o.f.visible = t >= o.at;
        o.f.position.y = o.f.userData.base + (1 - k * k) * 40;  // fällt von oben auf seinen Platz
        o.l.style.opacity = k >= 1 ? 1 : 0;
        if (k >= 1 && o.i === 0 && !o.cheered) { o.cheered = true; box.dispatchEvent(new CustomEvent('hvp-winner')); }
      });
      // leichte Kamerafahrt
      const a = Math.sin(t / 5200) * .06;
      cam.position.x = Math.sin(a) * dist;
      cam.lookAt(look);
      place();
      renderer.render(scene, cam);
      if (!opts.still) requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
    return {renderer, scene, cam};
  };

  // Stil der Beschriftungen
  const css = document.createElement('style');
  css.textContent = `
  .hvp{position:relative;overflow:hidden;border-radius:16px;background:#8ab8ff;}
  .hvp canvas{display:block;width:100%;height:100%;image-rendering:pixelated;}
  .hvp-labels{position:absolute;inset:0;pointer-events:none;}
  .hvp-label{position:absolute;transform:translate(-50%,-100%);display:flex;flex-direction:column;align-items:center;white-space:nowrap;
    font-family:"Segoe UI",system-ui,sans-serif;text-shadow:0 2px 0 #000,0 0 6px rgba(0,0,0,.7);transition:opacity .4s;}
  .hvp-label.below{transform:translate(-50%,0);}
  .hvp-label b{color:#fff;font-size:13px;background:rgba(0,0,0,.35);padding:1px 6px;border-radius:4px;}
  .hvp-label span{color:#ffd166;font:800 12px Consolas,monospace;}
  .hvp-label.top b{font-size:15px;}
  .hvp-label.p1 b{color:#ffe066;font-size:17px;}
  .hvp-label i{font-style:normal;font-size:26px;line-height:1;}
  .hvp-title{position:absolute;top:14px;left:0;right:0;text-align:center;font-family:"Segoe UI",system-ui,sans-serif;pointer-events:none;
    text-shadow:0 3px 0 #000,0 0 10px rgba(0,0,0,.6);}
  .hvp-title b{display:block;color:#fff;font-size:28px;}
  .hvp-title small{color:#ffe9a8;font-size:14px;font-weight:600;}`;
  document.head.appendChild(css);
})();
