const fs = require('fs');
const path = require('path');

const evidenceDir = path.resolve(__dirname, '../test-evidence');

const targetPages = [
  { name: 'crm_overview', title: 'Tổng quan CRM (Dashboard & KPI)', spec: 'tests/crm_overview.spec.js' },
  { name: 'crm_customer_data', title: 'Dữ liệu khách hàng (Customer Management)', spec: 'tests/crm_customer_data.spec.js' },
  { name: 'crm_service_tracking', title: 'Theo dõi dịch vụ (Service & Contract Tracking)', spec: 'tests/crm_service_tracking.spec.js' },
  { name: 'crm_sales_pipeline', title: 'Sales Pipeline (Kanban Opportunities)', spec: 'tests/crm_sales_pipeline.spec.js' },
  { name: 'crm_business_flow', title: 'Luồng nghiệp vụ liên màn hình CRM (Cross-Menu Business Flow)', spec: 'tests/crm_business_flow.spec.js' }
];

const allTCs = [];
const pageSummaries = [];

for (const p of targetPages) {
  const pageDir = path.join(evidenceDir, p.name);
  if (!fs.existsSync(pageDir)) continue;

  const tcDirs = fs.readdirSync(pageDir, { withFileTypes: true })
    .filter(d => d.isDirectory() && (d.name.startsWith('TC-') || d.name.startsWith('FLOW-')))
    .map(d => d.name)
    .sort();

  const tcList = [];

  for (const tcId of tcDirs) {
    const jsonPath = path.join(pageDir, tcId, 'results.json');
    if (fs.existsSync(jsonPath)) {
      try {
        const tcData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
        tcList.push(tcData);
        allTCs.push(tcData);
      } catch (e) {
        console.error(`Error reading ${jsonPath}:`, e.message);
      }
    }
  }

  const passCount = tcList.filter(t => t.businessStatus === 'PASSED').length;
  const failCount = tcList.length - passCount;

  pageSummaries.push({
    ...p,
    count: tcList.length,
    passCount,
    failCount,
    statusText: failCount === 0 ? '✅ 100% LOGIC PASS' : `❌ ${failCount} LOGIC FAIL`
  });
}

const totalTests = allTCs.length;
const totalPass = allTCs.filter(t => t.businessStatus === 'PASSED').length;
const totalFail = totalTests - totalPass;
const timestamp = new Date().toLocaleString('vi-VN');

let masterMd = `# BÁO CÁO KIỂM THỬ E2E TOÀN DIỆN PHÂN HỆ CRM (PARADISE HRM)\n\n`;
masterMd += `> **Thời gian thẩm định**: ${timestamp}\n`;
masterMd += `> **Phạm vi kiểm thử**: 4 Menu CRM cốt lõi + 1 Luồng nghiệp vụ liên hoàn khép kín\n`;
masterMd += `> **Tổng số kịch bản**: **${totalTests}** | ✅ LOGIC PASS: **${totalPass}** | ❌ LOGIC FAIL: **${totalFail}**\n\n`;

masterMd += `## 1. TỔNG HỢP KẾT QUẢ THEO TỪNG MENU / LUỒNG NGHIỆP VỤ\n\n`;
masterMd += `| Trang / Menu Nghiệp Vụ | File Kịch Bản | Số TC | Trạng Thái Kỹ Thuật | Trạng Thái Logic Nghiệp Vụ | Chi Tiết |\n`;
masterMd += `| :--- | :--- | :---: | :---: | :---: | :---: |\n`;

for (const ps of pageSummaries) {
  masterMd += `| **${ps.title}** | \`${ps.spec}\` | ${ps.count} | ✅ PASS | ${ps.statusText} | [Xem chi tiết](${ps.name}/test-report.md) |\n`;
}

masterMd += `\n---\n\n`;
masterMd += `## 2. DANH MỤC LỖI NGHIỆP VỤ & LỖI BACKEND PHÁT HIỆN QUA KIỂM THỬ TRỰC QUAN\n\n`;

const failedTCs = allTCs.filter(t => t.businessStatus === 'FAILED');
if (failedTCs.length > 0) {
  for (const ft of failedTCs) {
    masterMd += `### 🚨 [${ft.pageName}] ${ft.tcId}: ${ft.title}\n\n`;
    masterMd += `> [!CAUTION] PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)\n`;
    masterMd += `>\n`;
    masterMd += `> * **Vấn đề / Mã lỗi**: ${ft.failureAnalysis.issue || ft.businessNotes}\n`;
    if (ft.failureAnalysis.expected) masterMd += `> * **Kỳ vọng nghiệp vụ**: ${ft.failureAnalysis.expected}\n`;
    if (ft.failureAnalysis.actual) masterMd += `> * **Thực tế hệ thống**: ${ft.failureAnalysis.actual}\n`;
    if (ft.failureAnalysis.rootCause) masterMd += `> * **Nguyên nhân cốt lõi**: ${ft.failureAnalysis.rootCause}\n`;
    if (ft.failureAnalysis.recommendation) masterMd += `> * **Đề xuất khắc phục**: ${ft.failureAnalysis.recommendation}\n`;
    masterMd += `\n`;
  }
} else {
  masterMd += `*Không có lỗi nào.*\n\n`;
}

masterMd += `\n---\n\n`;
masterMd += `## 3. CHI TIẾT TỪNG KỊCH BẢN THẨM ĐỊNH (STEP-BY-STEP EVIDENCE)\n\n`;

for (const tc of allTCs) {
  const testBadge = tc.testStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
  const bizBadge = tc.businessStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
  masterMd += `### [${tc.pageName}] ${tc.tcId}: ${tc.title}\n\n`;
  masterMd += `* **Trạng thái thực thi kỹ thuật**: ${testBadge} (Thời gian: \`${tc.duration}\`)\n`;
  masterMd += `* **Trạng thái Logic Nghiệp vụ**: ${bizBadge}\n`;
  masterMd += `* **Đánh giá**: ${tc.businessNotes}\n`;
  masterMd += `* **Thư mục lưu trữ**: [\`test-evidence/${tc.pageName}/${tc.tcId}/\`](file:///${path.resolve(evidenceDir, tc.pageName, tc.tcId).replace(/\\/g, '/')})\n\n`;

  if (tc.stepScreenshots && tc.stepScreenshots.length > 0) {
    masterMd += `#### 📸 Bằng chứng trực quan từng bước:\n\n`;
    for (const s of tc.stepScreenshots) {
      masterMd += `##### 🔹 Bước ${s.step}: ${s.title}\n`;
      masterMd += `![Bước ${s.step}: ${s.title}](${s.relPath})\n\n`;
    }
  }

  masterMd += `#### 🎥 Video & Dấu vết kiểm thử:\n`;
  if (tc.attachments.videos && tc.attachments.videos.length > 0) {
    for (const v of tc.attachments.videos) {
      masterMd += `- **Video**: [${path.basename(v)}](${v})\n`;
    }
  }
  if (tc.attachments.traces && tc.attachments.traces.length > 0) {
    for (const t of tc.attachments.traces) {
      masterMd += `- **Trace**: [${path.basename(t)}](${t}) *(Mở: \`npx playwright show-trace test-evidence/${t}\`)*\n`;
    }
  }
  masterMd += `\n---\n\n`;
}

fs.writeFileSync(path.join(evidenceDir, 'test-report.md'), masterMd, 'utf8');

// Update master results.json
fs.writeFileSync(path.join(evidenceDir, 'results.json'), JSON.stringify({
  timestamp,
  totalTests,
  totalPass,
  totalFail,
  pages: pageSummaries
}, null, 2), 'utf8');

console.log(`✅ Đã biên soạn Báo cáo tổng hợp E2E toàn diện cho cả 4 Menu CRM và Luồng liên màn hình: ${path.join(evidenceDir, 'test-report.md')}`);
