const fs = require('fs');
const lines = fs.readFileSync('scripts/detailed_clicks.txt', 'utf-8').split('\n');
lines.forEach(l => {
  const m = l.match(/^(\[[^\]]+\])/);
  const tag = m ? m[1] : '';
  if (l.includes('HitTest')) {
    const nm = l.match(/"nodeName":"([^"]+)"/);
    const nid = l.match(/"nodeId":(\d+)/);
    const xy = l.match(/"x":(\d+),"y":(\d+)/);
    console.log(`${tag} HitTest node=${nid?.[1]} ${nm?.[1]} (${xy?.[1]},${xy?.[2]})`);
  } else if (l.includes('EventDispatch')) {
    const t = l.match(/"type":"([^"]+)"/);
    console.log(`${tag} Event=${t?.[1]}`);
  } else if (l.includes('ResourceSendRequest')) {
    console.log(`${tag} NET_SEND`);
  } else if (l.includes('ScriptCatchup')) {
    const src = l.match(/"sourceText":"([^"]{0,80})/);
    const sid = l.match(/"scriptId":(\d+)/);
    if (src) console.log(`${tag} ScriptCatchup (${sid?.[1]}): ${src[1]}`);
  } else if (l.includes('ScheduleStyleRecalculation') || l.includes('UpdateLayoutTree')) {
    const frames = [...l.matchAll(/"functionName":"([^"]*)","lineNumber":(\d+),"scriptId":"(\d+)"/g)].map(x => `${x[1]||'anon'}@${x[2]}(${x[3]})`).slice(0, 6);
    if (frames.length) console.log(`${tag} Stack: ${frames.join(' <- ')}`);
  }
});
