const fs = require('fs');

let content = fs.readFileSync('fix-bug/screenshot-1/patch_responsive.sql', 'utf8');

// Replace comment
content = content.replace(
  '// 5. Trạng thái: 20% (minWidth 180, hidingPriority: 1 - Căn giữa đối xứng)',
  '// 5. Trạng thái: 20% (minWidth 180, hidingPriority: 1 - Căn trái nội dung theo yêu cầu)'
);

// Replace alignment: "center" for Status_History
const oldBlock = `caption: "%Status%", 
                        dataField: "Status_History", 
                        width: "20%", 
                        minWidth: 180, 
                        alignment: "center",
                        hidingPriority: 1,
                        cellTemplate: function(container, options) {
                            container.addClass("text-center");`;

// Handle both \r\n and \n
const oldBlockCRLF = oldBlock.replace(/\n/g, '\r\n');
const newBlockCRLF = `caption: "%Status%", 
                        dataField: "Status_History", 
                        width: "20%", 
                        minWidth: 180, 
                        alignment: "left",
                        hidingPriority: 1,
                        cellTemplate: function(container, options) {`.replace(/\n/g, '\r\n');

if (content.includes(oldBlockCRLF)) {
  content = content.replace(oldBlockCRLF, newBlockCRLF);
  fs.writeFileSync('fix-bug/screenshot-1/patch_responsive.sql', content, 'utf8');
  console.log('Successfully updated patch_responsive.sql (CRLF)!');
} else if (content.includes(oldBlock)) {
  content = content.replace(oldBlock, newBlockCRLF.replace(/\r\n/g, '\n'));
  fs.writeFileSync('fix-bug/screenshot-1/patch_responsive.sql', content, 'utf8');
  console.log('Successfully updated patch_responsive.sql (LF)!');
} else {
  console.log('Block not found, checking details...');
}
