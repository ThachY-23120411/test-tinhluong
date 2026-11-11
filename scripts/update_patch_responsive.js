const fs = require('fs');
const path = require('path');

const targetFile = path.join(__dirname, '..', 'fix-bug', 'screenshot-1', 'patch_responsive.sql');
let content = fs.readFileSync(targetFile, 'utf8');

const targetStr = `                columnAutoWidth: true,
                paging: { pageSize: 20 },
                pager: { showPageSizeSelector: true, allowedPageSizes: [20, 50, 100], showInfo: true, visible: true },
                allowColumnResizing: true,       // Bật tính năng kéo thả độ rộng cột
                columnResizingMode: "widget",    // Co giãn mượt mà theo khung widget
                columnHidingEnabled: true,       // Tự động gập cột trên màn hình nhỏ
                wordWrapEnabled: false,
                columns: [
                    // 1. Ngày đổi: 16% (minWidth 150, hidingPriority: 3)
                    { 
                        caption: "%RedemptionDateLabel%", 
                        dataField: "OrderDate", 
                        dataType: "date", 
                        format: "dd/MM/yyyy HH:mm", 
                        width: "16%", 
                        minWidth: 150, 
                        hidingPriority: 3 
                    },
                    // 2. Nhân viên: 22% (minWidth 180, hidingPriority: 5)
                    { 
                        caption: "%colEmployeeName%", 
                        width: "22%", 
                        minWidth: 180, 
                        hidingPriority: 5,
                        cellTemplate: function(container, options) { 
                            $("<div>").addClass("fw-bold text-truncate").attr("title", options.data.FullName || "Unknown").text(options.data.FullName || "Unknown").appendTo(container); 
                        } 
                    },
                    // 3. Quà tặng: 28% (minWidth 220, hidingPriority: 4)
                    {
                        caption: "%GiftsLabel%",
                        width: "28%",
                        minWidth: 220,
                        hidingPriority: 4,
                        cellTemplate: function(container, options) {
                            var d = options.data;
                            var img = d.ImageURL && d.ImageURL.trim() !== '''' ? d.ImageURL : ''data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'';
                            var wrapper = $("<div>").addClass("d-flex align-items-center gap-2");
                            $("<img>").addClass("product-thumb").attr("src", img).appendTo(wrapper);
                            $("<div>").addClass("text-truncate").attr("title", d.ProductName || "").text(d.ProductName || "").appendTo(wrapper);
                            wrapper.appendTo(container);
                        }
                    },
                    // 4. Coin: 14% (minWidth 100, hidingPriority: 2 - Căn phải)
                    { 
                        caption: "Coin", 
                        dataField: "TotalCoins", 
                        width: "14%", 
                        minWidth: 100, 
                        alignment: "right", 
                        hidingPriority: 2,
                        cellTemplate: function(c, o) { 
                            $("<span>").addClass("text-danger fw-bold").text(formatNumber(o.value)).appendTo(c); 
                        } 
                    },
                    // 5. Trạng thái: 20% (minWidth 180, hidingPriority: 1 - Căn giữa)
                    {
                        caption: "%Status%", 
                        dataField: "Status_History", 
                        width: "20%", 
                        minWidth: 180, 
                        alignment: "center",
                        hidingPriority: 1,
                        cellTemplate: function(container, options) {
                            var st = options.value;
                            var cls = "badge-pending";
                            var icon = "bi-hourglass-split";

                            if(st === "Đã nhận") { cls = "badge-approved"; icon = "bi-check-circle-fill"; }
                            else if(st === "Trả hàng" || st === "Đã hủy" || st === "Đã trả hàng") { cls = "badge-rejected"; icon = "bi-x-circle-fill"; }
                            else if(st && st.indexOf("Yêu cầu") >= 0) { cls = "badge-request"; icon = "bi-exclamation-circle-fill"; }

                            $("<span>").addClass("badge-status " + cls).html(\`<i class="bi \${icon}"></i> \${st}\`).appendTo(container);
                        }
                    }
                ],`;

const replacementStr = `                columnAutoWidth: false,          // Tắt autoWidth để DevExtreme chia đúng 100% theo tỷ lệ % cấu hình
                paging: { pageSize: 20 },
                pager: { showPageSizeSelector: true, allowedPageSizes: [20, 50, 100], showInfo: true, visible: true },
                allowColumnResizing: true,       // Bật tính năng kéo thả độ rộng cột
                columnResizingMode: "widget",    // Co giãn mượt mà theo khung widget
                columnHidingEnabled: true,       // Tự động gập cột trên màn hình nhỏ
                wordWrapEnabled: false,
                columns: [
                    // 1. Ngày đổi: 20% (minWidth 150, hidingPriority: 3 - Căn trái)
                    { 
                        caption: "%RedemptionDateLabel%", 
                        dataField: "OrderDate", 
                        dataType: "date", 
                        format: "dd/MM/yyyy HH:mm", 
                        width: "20%", 
                        minWidth: 150, 
                        alignment: "left",
                        hidingPriority: 3 
                    },
                    // 2. Nhân viên: 20% (minWidth 160, hidingPriority: 5 - Căn trái)
                    { 
                        caption: "%colEmployeeName%", 
                        width: "20%", 
                        minWidth: 160, 
                        alignment: "left",
                        hidingPriority: 5,
                        cellTemplate: function(container, options) { 
                            $("<div>").addClass("fw-bold text-truncate").attr("title", options.data.FullName || "Unknown").text(options.data.FullName || "Unknown").appendTo(container); 
                        } 
                    },
                    // 3. Quà tặng: 20% (minWidth 160, hidingPriority: 4 - Căn trái)
                    {
                        caption: "%GiftsLabel%",
                        width: "20%",
                        minWidth: 160, 
                        alignment: "left",
                        hidingPriority: 4,
                        cellTemplate: function(container, options) {
                            var d = options.data;
                            var img = d.ImageURL && d.ImageURL.trim() !== '''' ? d.ImageURL : ''data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'';
                            var wrapper = $("<div>").addClass("d-flex align-items-center gap-2");
                            $("<img>").addClass("product-thumb").attr("src", img).appendTo(wrapper);
                            $("<div>").addClass("text-truncate").attr("title", d.ProductName || "").text(d.ProductName || "").appendTo(wrapper);
                            wrapper.appendTo(container);
                        }
                    },
                    // 4. Coin: 20% (minWidth 110, hidingPriority: 2 - Căn giữa đối xứng)
                    { 
                        caption: "Coin", 
                        dataField: "TotalCoins", 
                        width: "20%", 
                        minWidth: 110, 
                        alignment: "center", 
                        hidingPriority: 2,
                        cellTemplate: function(c, o) { 
                            $("<span>").addClass("text-danger fw-bold").text(formatNumber(o.value)).appendTo(c); 
                        } 
                    },
                    // 5. Trạng thái: 20% (minWidth 180, hidingPriority: 1 - Căn giữa đối xứng)
                    {
                        caption: "%Status%", 
                        dataField: "Status_History", 
                        width: "20%", 
                        minWidth: 180, 
                        alignment: "center",
                        hidingPriority: 1,
                        cellTemplate: function(container, options) {
                            var st = options.value;
                            var cls = "badge-pending";
                            var icon = "bi-hourglass-split";

                            if(st === "Đã nhận") { cls = "badge-approved"; icon = "bi-check-circle-fill"; }
                            else if(st === "Trả hàng" || st === "Đã hủy" || st === "Đã trả hàng") { cls = "badge-rejected"; icon = "bi-x-circle-fill"; }
                            else if(st && st.indexOf("Yêu cầu") >= 0) { cls = "badge-request"; icon = "bi-exclamation-circle-fill"; }

                            $("<span>").addClass("badge-status " + cls).html(\`<i class="bi \${icon}"></i> \${st}\`).appendTo(container);
                        }
                    }
                ],`;

// Normalize line endings for replacement
const normalize = s => s.replace(/\r\n/g, '\n');
const normalizedContent = normalize(content);
const normalizedTarget = normalize(targetStr);
const normalizedReplacement = normalize(replacementStr);

if (normalizedContent.includes(normalizedTarget)) {
    const updated = normalizedContent.replace(normalizedTarget, normalizedReplacement);
    // Write back with CRLF if original had CRLF
    const output = content.includes('\r\n') ? updated.replace(/\n/g, '\r\n') : updated;
    fs.writeFileSync(targetFile, output, 'utf8');
    console.log('SUCCESS: patch_responsive.sql updated to 20% uniform distribution!');
} else {
    console.error('Target string not found in patch_responsive.sql');
}
