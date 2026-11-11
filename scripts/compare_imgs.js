const fs = require('fs');

console.log('Comparing Screenshots_1_bug/5.png vs user upload...');
const f1 = fs.readFileSync('Screenshots_1_bug/5.png');
const f2 = fs.readFileSync('C:/Antigravity_MultiAccount/Profiles/Profile11/.gemini/antigravity/brain/80ff1d52-7a74-485b-8c0e-59ef6911cd5d/.user_uploaded/media_1792558321840_4ffb34fd.png');

console.log('Size 5.png:', f1.length);
console.log('Size user upload:', f2.length);
