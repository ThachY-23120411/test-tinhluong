const fs = require('fs');

const orig = fs.readFileSync('scripts/sp_Debt_PaymentDebt_html.sql', 'utf8');

// 1. Old CSS target to replace
const oldCss = `    #sp_payment_debt .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 1rem !important;
        height: 60px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }

    #sp_payment_debt .dx-datagrid-row>td {
        padding: 0.75rem 1rem !important;
        vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }`;

const newCss = `    #sp_payment_debt .dx-datagrid-headers .dx-header-row>td {
        font-weight: 700 !important;
        padding: 0.75rem 0.5rem !important;
        height: 52px !important;
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
        white-space: nowrap;
    }

    #sp_payment_debt .dx-datagrid-row>td {
        padding: 0.65rem 0.5rem !important;
        vertical-align: middle !important;
        border-bottom: 1px solid rgba(128, 128, 128, 0.1) !important;
    }`;

// 2. Old Grid target to replace
// Let's find the start and end of dxDataGrid in orig
const startKeyword = 'gridInstance = $("#dp_grid").dxDataGrid({';
const endKeyword = '}).dxDataGrid("instance");';

const startPos = orig.indexOf(startKeyword);
const endPos = orig.indexOf(endKeyword, startPos) + endKeyword.length;

if (startPos === -1 || endPos === -1) {
  console.error('Cannot find gridInstance block!');
  process.exit(1);
}

const oldGridBlock = orig.slice(startPos, endPos);

const newGridBlock = `gridInstance = $("#dp_grid").dxDataGrid({
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
                                        var day = String(d.getDate()).padStart(2, ''0'');
                                        var month = String(d.getMonth() + 1).padStart(2, ''0'');
                                        var year = d.getFullYear();
                                        $("<div>").text(day + ''/'' + month + ''/'' + year).appendTo(container);
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

let patched = orig.replace(oldCss, newCss);
patched = patched.replace(oldGridBlock, newGridBlock);

// Make sure it has ALTER PROCEDURE [dbo].[sp_Debt_PaymentDebt_html]
patched = patched.replace('CREATE PROCEDURE [dbo].[sp_Debt_PaymentDebt_html]', 'ALTER PROCEDURE [dbo].[sp_Debt_PaymentDebt_html]');

fs.writeFileSync('scripts/patched_sp_Debt_PaymentDebt_html.sql', patched, 'utf8');
console.log('Success! Patched file created, length:', patched.length);
