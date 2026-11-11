const fs = require('fs');

const orig = fs.readFileSync('scripts/sp_Debt_PaymentDebt_html.sql', 'utf8');

const targetOld = `                gridInstance = $("#dp_grid").dxDataGrid({
                    dataSource: filteredData,
                    keyExpr: "RecordID", // Khóa chính của bảng

                    showBorders: false,
                    hoverStateEnabled: true,
                    columnAutoWidth: true,
                    paging: { pageSize: 15 },
                    pager: { showPageSizeSelector: true, allowedPageSizes: [15, 30, 50], showInfo: true, visible: true },
                    columns: [
                        {
                            caption: "%Debt_CustomerLabel%",
                            minWidth: 150,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                $("<div>").addClass("fw-bold").text(d.CustomerName).appendTo(container);
                                $("<div>").addClass("small opacity-75").text(d.CustomerCode).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_DebtTypeLabel%",
                            dataField: "DebtType",
                            width: 120
                        },
                        {
                            dataField: "Amount",
                            caption: "%Debt_TotalDebtLabel%",
                            width: 120,
                            alignment: "right",
                            format: "#,##0" // Định dạng tiền
                        },
                        {
                            caption: "%Debt_PaidAmountLabel%",
                            width: 110,
                            alignment: "right",
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var paidAmount = d.PaidAmount || 0;
                                $("<div>").addClass("text-success fw-bold").text(formatNumber(paidAmount)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_RemainingDebtLabel%",
                            width: 110,
                            alignment: "right",
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                $("<div>").addClass("text-danger fw-bold").text(formatNumber(remaining)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Contact%",
                            width: 150,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                if (d.PhoneNumber) $("<div>").html(\`<i class="bi bi-telephone me-1"></i>\${d.PhoneNumber}\`).appendTo(container);
                                if (d.Address) $("<div>").addClass("small text-truncate").attr("title", d.Address).text(d.Address).appendTo(container);
                            }
                        },
                        {
                            dataField: "Status",
                            caption: "%Status%",
                            width: 140,
                            alignment: "center",
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                var statusFromDB = d.Status || 0; // Status từ DB: 0 = chưa thanh toán, 1 = đã thanh toán

                                // Ưu tiên Status từ DB, nếu Status = 1 thì hiển thị "Đã thanh toán"
                                // Nếu Status = 0, thì mới kiểm tra số tiền thực tế
                                var badgeClass, text;
                                if (statusFromDB === 1) {
                                    // Status = 1: Đã thanh toán (từ DB hoặc Excel import)
                                    badgeClass = "badge-paid";
                                    text = "%Debt_PaidStatus%";
                                } else {
                                    // Status = 0: Kiểm tra số tiền thực tế
                                    var isFullyPaid = remaining <= 0 && paidAmount > 0;
                                    var isPartiallyPaid = paidAmount > 0 && remaining > 0;
                                    if (isFullyPaid) {
                                        badgeClass = "badge-paid";
                                        text = "%Debt_PaidStatus%";
                                    } else if (isPartiallyPaid) {
                                        badgeClass = "badge-partial";
                                        text = "%Debt_PartialPaidStatus%";
                                    } else {
                                        badgeClass = "badge-unpaid";
                                        text = "%Debt_UnpaidStatus%";
                                    }
                                }

                                $("<span>").addClass("badge-status " + badgeClass).text(text).appendTo(container);
                            }
                        },
                        {
                            dataField: "ExpiryDate",
                            caption: "%Debt_ExpiryDateLabel%",
                            alignment: "center",
                            width: 120,
                            cellTemplate: function (container, options) {
                                var val = options.value;
                                if (val) {
                                    var d = new Date(val);
                                    if (!isNaN(d.getTime())) {
                                        var day = String(d.getDate()).padStart(2, '0');
                                        var month = String(d.getMonth() + 1).padStart(2, '0');
                                        var year = d.getFullYear();
                                        $("<div>").text(day + '/' + month + '/' + year).appendTo(container);
                                    } else {
                                        // Fallback old format if not parsed
                                        $("<div>").text(val).appendTo(container);
                                    }
                                } else {
                                    $("<div>").text("-").appendTo(container);
                                }
                            }
                        }
                    ],
                    onRowClick: function (e) { openEditModal(e.data.RecordID); }
                }).dxDataGrid("instance");`;

const targetNew = `                gridInstance = $("#dp_grid").dxDataGrid({
                    dataSource: filteredData,
                    keyExpr: "RecordID", // Khóa chính của bảng

                    showBorders: false,
                    showRowLines: true,
                    showColumnLines: false,
                    hoverStateEnabled: true,
                    columnAutoWidth: true,
                    allowColumnResizing: true,
                    columnResizingMode: "widget",
                    columnHidingEnabled: true,
                    wordWrapEnabled: false,
                    noDataText: "%Debt_NoData%",
                    paging: { pageSize: 15 },
                    pager: { showPageSizeSelector: true, allowedPageSizes: [15, 30, 50], showInfo: true, visible: true },
                    columns: [
                        {
                            caption: "%Debt_CustomerLabel%",
                            minWidth: 180,
                            width: "18%",
                            hidingPriority: 8,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                $("<div>").addClass("fw-bold text-truncate").attr("title", d.CustomerName).text(d.CustomerName).appendTo(container);
                                $("<div>").addClass("small opacity-75").text(d.CustomerCode).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_DebtTypeLabel%",
                            dataField: "DebtType",
                            minWidth: 140,
                            width: "13%",
                            hidingPriority: 5,
                            cellTemplate: function (container, options) {
                                var val = options.value || "";
                                $("<div>").addClass("text-truncate").attr("title", val).text(val).appendTo(container);
                            }
                        },
                        {
                            dataField: "Amount",
                            caption: "%Debt_TotalDebtLabel%",
                            minWidth: 130,
                            width: "11%",
                            alignment: "right",
                            format: "#,##0",
                            hidingPriority: 6
                        },
                        {
                            caption: "%Debt_PaidAmountLabel%",
                            minWidth: 110,
                            width: "9%",
                            alignment: "right",
                            hidingPriority: 3,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var paidAmount = d.PaidAmount || 0;
                                $("<div>").addClass("text-success fw-bold").text(formatNumber(paidAmount)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Debt_RemainingDebtLabel%",
                            minWidth: 110,
                            width: "10%",
                            alignment: "right",
                            hidingPriority: 7,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                $("<div>").addClass("text-danger fw-bold").text(formatNumber(remaining)).appendTo(container);
                            }
                        },
                        {
                            caption: "%Contact%",
                            minWidth: 140,
                            width: "13%",
                            hidingPriority: 2,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                if (d.PhoneNumber) $("<div>").html(\`<i class="bi bi-telephone me-1"></i>\${d.PhoneNumber}\`).appendTo(container);
                                if (d.Address) $("<div>").addClass("small text-truncate").attr("title", d.Address).text(d.Address).appendTo(container);
                            }
                        },
                        {
                            dataField: "Status",
                            caption: "%Status%",
                            minWidth: 130,
                            width: "13%",
                            alignment: "center",
                            hidingPriority: 4,
                            cellTemplate: function (container, options) {
                                var d = options.data;
                                var totalAmount = d.Amount || 0;
                                var paidAmount = d.PaidAmount || 0;
                                var remaining = totalAmount - paidAmount;
                                var statusFromDB = d.Status || 0;

                                var badgeClass, text;
                                if (statusFromDB === 1) {
                                    badgeClass = "badge-paid";
                                    text = "%Debt_PaidStatus%";
                                } else {
                                    var isFullyPaid = remaining <= 0 && paidAmount > 0;
                                    var isPartiallyPaid = paidAmount > 0 && remaining > 0;
                                    if (isFullyPaid) {
                                        badgeClass = "badge-paid";
                                        text = "%Debt_PaidStatus%";
                                    } else if (isPartiallyPaid) {
                                        badgeClass = "badge-partial";
                                        text = "%Debt_PartialPaidStatus%";
                                    } else {
                                        badgeClass = "badge-unpaid";
                                        text = "%Debt_UnpaidStatus%";
                                    }
                                }

                                $("<span>").addClass("badge-status " + badgeClass).text(text).appendTo(container);
                            }
                        },
                        {
                            dataField: "ExpiryDate",
                            caption: "%Debt_ExpiryDateLabel%",
                            alignment: "center",
                            minWidth: 130,
                            width: "13%",
                            hidingPriority: 1,
                            cellTemplate: function (container, options) {
                                var val = options.value;
                                if (val) {
                                    var d = new Date(val);
                                    if (!isNaN(d.getTime())) {
                                        var day = String(d.getDate()).padStart(2, '0');
                                        var month = String(d.getMonth() + 1).padStart(2, '0');
                                        var year = d.getFullYear();
                                        $("<div>").text(day + '/' + month + '/' + year).appendTo(container);
                                    } else {
                                        $("<div>").text(val).appendTo(container);
                                    }
                                } else {
                                    $("<div>").text("-").appendTo(container);
                                }
                            }
                        }
                    ],
                    onRowClick: function (e) { openEditModal(e.data.RecordID); }
                }).dxDataGrid("instance");`;

// Also check the header padding CSS:
const oldCss = `    #sp_payment_debt .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 1rem !important;
        height: 60px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }`;

const newCss = `    #sp_payment_debt .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 0.75rem 0.6rem !important;
        height: 52px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
        white-space: nowrap;
    }

    #sp_payment_debt .dx-datagrid-row>td {
        padding: 0.65rem 0.6rem !important;
        vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }`;

console.log('Old code present in orig?', orig.includes(targetOld.trim()));
console.log('Old CSS present in orig?', orig.includes(oldCss.trim()));

// Let's do a replace and generate the proposed file
let patched = orig.replace(oldCss, newCss);
// For targetOld, because in SQL single quotes are escaped as ''
// Notice in orig file, how are single quotes escaped?
const lines = orig.split('\n');
console.log('Line 880 sample from orig:');
console.log(lines[879]);
