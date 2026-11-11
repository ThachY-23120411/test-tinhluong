const fs = require('fs');
const readline = require('readline');

async function extractUserPrompts(convId) {
  const p = `C:/Antigravity_MultiAccount/Profiles/Profile11/.gemini/antigravity/brain/${convId}/.system_generated/logs/transcript.jsonl`;
  if (!fs.existsSync(p)) {
    console.log(`Path not found: ${p}`);
    return;
  }
  console.log(`\n======================================================`);
  console.log(`CONVERSATION: ${convId}`);
  console.log(`======================================================`);

  const fileStream = fs.createReadStream(p);
  const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

  let idx = 0;
  for await (const line of rl) {
    if (!line.trim()) continue;
    try {
      const obj = JSON.parse(line);
      if (obj.type === 'USER_INPUT' || obj.source === 'USER_EXPLICIT') {
        const text = typeof obj.content === 'string' ? obj.content : JSON.stringify(obj.content);
        console.log(`[${idx++}] USER: ${text.substring(0, 300)}`);
      }
    } catch (e) {}
  }
}

async function main() {
  await extractUserPrompts('34c6ffcf-084b-4048-840e-3bed86e40404');
  await extractUserPrompts('0177f08f-a29d-4439-b272-1cd61bb4d824');
}

main();
