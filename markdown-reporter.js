const fs = require('fs');
const path = require('path');

class HierarchicalMarkdownReporter {
  constructor(options = {}) {
    this.outputDir = options.outputDir || path.resolve(process.cwd(), 'test-evidence');
    this.allResults = [];
    this.pageResults = {}; // { pageName: [ tcResult, ... ] }
  }

  onBegin(config, suite) {
    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
    }
  }

  onTestEnd(test, result) {
    // 1. Xác định tên trang từ tên file .spec.js
    const specFilePath = test.location ? test.location.file : '';
    let pageName = 'common';
    if (specFilePath) {
      pageName = path.basename(specFilePath)
        .replace(/\.spec\.[jt]s$/, '')
        .replace(/\.[jt]s$/, '');
    }

    // 2. Xác định mã TC (ví dụ TC-01, TC-02) từ tiêu đề test
    const tcMatch = test.title.match(/TC-(\d+)/i);
    let tcId = tcMatch ? tcMatch[0].toUpperCase() : `TC-${String((this.pageResults[pageName] || []).length + 1).padStart(2, '0')}`;

    // 3. Khởi tạo thư mục theo cấp bậc: test-evidence/<pageName>/<tcId>/
    const tcDir = path.join(this.outputDir, pageName, tcId);
    const screenshotsDir = path.join(tcDir, 'screenshots');
    const videosDir = path.join(tcDir, 'videos');
    const tracesDir = path.join(tcDir, 'traces');

    for (const dir of [screenshotsDir, videosDir, tracesDir]) {
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
    }

    const durationSec = (result.duration / 1000).toFixed(2);
    const status = result.status.toUpperCase();

    // 4. Thu thập thông tin tên bước tiếng Việt có dấu từ testInfo.attach
    const stepTitleMap = {};
    for (const att of result.attachments || []) {
      if (att.name && /bước\s*(\d+)[:\s-]*(.*)/i.test(att.name)) {
        const m = att.name.match(/bước\s*(\d+)[:\s-]*(.*)/i);
        stepTitleMap[parseInt(m[1], 10)] = m[2].trim();
      }
    }

    // 5. Thu thập video và trace
    const videos = [];
    const traces = [];

    for (const att of result.attachments || []) {
      if (att.name === 'video' || (att.path && att.path.endsWith('.webm'))) {
        const dest = path.join(videosDir, path.basename(att.path));
        try { fs.copyFileSync(att.path, dest); } catch (_) {}
        const rel = `${pageName}/${tcId}/videos/${path.basename(att.path)}`;
        if (!videos.includes(rel)) videos.push(rel);
      } else if (att.name === 'trace' || (att.path && att.path.endsWith('.zip'))) {
        const dest = path.join(tracesDir, path.basename(att.path));
        try { fs.copyFileSync(att.path, dest); } catch (_) {}
        const rel = `${pageName}/${tcId}/traces/${path.basename(att.path)}`;
        if (!traces.includes(rel)) traces.push(rel);
      }
    }

    if (result.video) {
      try {
        const vPath = result.video.path();
        if (fs.existsSync(vPath)) {
          const dest = path.join(videosDir, path.basename(vPath));
          fs.copyFileSync(vPath, dest);
          const relPath = `${pageName}/${tcId}/videos/${path.basename(vPath)}`;
          if (!videos.includes(relPath)) videos.push(relPath);
        }
      } catch (_) {}
    }

    // 6. Quét các file ảnh chụp thực tế trong thư mục screenshots của TC
    const stepScreenshots = [];
    const fallbackScreenshots = [];

    if (fs.existsSync(screenshotsDir)) {
      const files = fs.readdirSync(screenshotsDir);
      for (const fn of files) {
        if (!fn.endsWith('.png')) continue;

        // Bỏ qua các file rác có mã băm ngẫu nhiên hex dài hoặc trùng lặp tự sinh
        if (/[a-f0-9]{20,}\.png$/i.test(fn)) {
          try { fs.unlinkSync(path.join(screenshotsDir, fn)); } catch (_) {}
          continue;
        }

        if (/^test-(finished|failed)-\d+\.png$/i.test(fn)) {
          fallbackScreenshots.push({
            step: 99,
            title: 'Ảnh chụp màn hình kết quả',
            fileName: fn,
            relPath: `${pageName}/${tcId}/screenshots/${fn}`
          });
          continue;
        }

        // Bóc tách số thứ tự bước từ tên file (ví dụ: TC-01-step02-mo-man-hinh.png)
        let stepNum = 99;
        let stepTitle = fn.replace(/\.png$/i, '');

        if (/step0?(\d+)/i.test(fn)) {
          const m = fn.match(/step0?(\d+)/i);
          stepNum = parseInt(m[1], 10);
        }

        // Ưu tiên lấy tiêu đề tiếng Việt chuẩn có dấu nếu có trong stepTitleMap
        if (stepTitleMap[stepNum]) {
          stepTitle = stepTitleMap[stepNum];
        } else {
          stepTitle = stepTitle.replace(/^TC-\d+[-_]step\d+[-_]?/i, '').replace(/[-_]+/g, ' ');
          stepTitle = stepTitle.charAt(0).toUpperCase() + stepTitle.slice(1);
        }

        stepScreenshots.push({
          step: stepNum,
          title: stepTitle,
          fileName: fn,
          relPath: `${pageName}/${tcId}/screenshots/${fn}`
        });
      }
    }

    // Sắp xếp các bước theo thứ tự tăng dần 1, 2, 3...
    stepScreenshots.sort((a, b) => a.step - b.step);

    // Nếu có ảnh chụp theo bước thì xóa bỏ test-finished thừa để không làm loãng báo cáo
    if (stepScreenshots.length > 0) {
      for (const fb of fallbackScreenshots) {
        try { fs.unlinkSync(path.join(screenshotsDir, fb.fileName)); } catch (_) {}
      }
    }

    const finalScreenshots = stepScreenshots.length > 0 ? stepScreenshots : fallbackScreenshots;

    // 7. Đánh giá Trạng thái kép: Kỹ thuật (Playwright) và Logic Nghiệp vụ
    const bizAnn = (test.annotations || []).find(a => a.type === 'business_status');
    const analysisAnn = (test.annotations || []).find(a => a.type === 'business_analysis');

    let businessStatus = 'PASSED';
    let businessNotes = 'Đạt yêu cầu logic nghiệp vụ mong đợi';
    let failureAnalysis = {
      issue: '',
      expected: '',
      actual: '',
      rootCause: '',
      recommendation: ''
    };

    if (bizAnn) {
      const desc = bizAnn.description || '';
      if (desc.toUpperCase().startsWith('FAIL')) {
        businessStatus = 'FAILED';
      }
      businessNotes = desc;
    } else if (status !== 'PASSED') {
      businessStatus = 'FAILED';
      businessNotes = (result.errors || []).map(e => e.message || e.value).join('\n') || 'Lỗi thực thi trong quá trình test';
    }

    // Trích xuất chi tiết phân tích lỗi nếu có
    if (analysisAnn && analysisAnn.description) {
      try {
        const parsed = JSON.parse(analysisAnn.description);
        failureAnalysis = { ...failureAnalysis, ...parsed };
      } catch (_) {
        failureAnalysis.issue = analysisAnn.description;
      }
    } else if (businessStatus === 'FAILED') {
      const expMatch = businessNotes.match(/Kỳ vọng[:\s]+([^,)]+)/i);
      const actMatch = businessNotes.match(/Thực tế[:\s]+([^,)]+)/i);
      failureAnalysis.issue = businessNotes;
      if (expMatch) failureAnalysis.expected = expMatch[1].trim();
      if (actMatch) failureAnalysis.actual = actMatch[1].trim();
      failureAnalysis.rootCause = 'Dữ liệu backend hoặc thao tác xử lý không cập nhật đúng vào cơ sở dữ liệu/giao diện';
      failureAnalysis.recommendation = 'Kiểm tra Stored Procedure xử lý nghiệp vụ và luồng nạp dữ liệu lên form';
    }

    let cleanTitle = test.title.replace(new RegExp(`^${tcId}[:\\s-]*`, 'i'), '').trim();

    const tcResult = {
      tcId,
      pageName,
      title: cleanTitle,
      testStatus: status,
      businessStatus: businessStatus,
      businessNotes: businessNotes,
      failureAnalysis,
      status: (status === 'PASSED' && businessStatus === 'PASSED') ? 'PASSED' : 'FAILED',
      duration: `${durationSec}s`,
      errors: (result.errors || []).map(e => e.message || e.value).join('\n'),
      stepScreenshots: finalScreenshots,
      attachments: {
        screenshots: finalScreenshots.map(s => s.relPath),
        videos,
        traces
      },
      timestamp: new Date().toISOString()
    };

    // Ghi results.json riêng cho từng TC
    const tcJsonPath = path.join(tcDir, 'results.json');
    fs.writeFileSync(tcJsonPath, JSON.stringify(tcResult, null, 2), 'utf8');

    // Tự động tạo file Run-This-TC.bat ngay trong thư mục TC-0x
    const batPath = path.join(tcDir, 'Run-This-TC.bat');
    const batContent = `@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: ${pageName} - ${tcId}
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: ${tcId} (${pageName}.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\\..\\.."
if not exist "node_modules" (
    cd /d "c:\\Users\\Y.Thach\\Desktop\\paradiseHR"
)
call npx playwright test tests/${pageName}.spec.js -g "${tcId}" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
`;
    fs.writeFileSync(batPath, batContent, 'utf8');

    if (!this.pageResults[pageName]) {
      this.pageResults[pageName] = [];
    }
    this.pageResults[pageName].push(tcResult);
    this.allResults.push(tcResult);
  }

  async onEnd(result) {
    const timestamp = new Date().toLocaleString('vi-VN');

    // 1. Tạo file báo cáo & file .bat riêng cho từng trang: test-evidence/<pageName>/
    for (const pageName of Object.keys(this.pageResults)) {
      const list = this.pageResults[pageName];
      const pageDir = path.join(this.outputDir, pageName);

      // Tạo Run-This-Page.bat
      const pageBatPath = path.join(pageDir, 'Run-This-Page.bat');
      const pageBatContent = `@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang ${pageName}
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: ${pageName}.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\\.."
if not exist "node_modules" (
    cd /d "c:\\Users\\Y.Thach\\Desktop\\paradiseHR"
)
call npx playwright test tests/${pageName}.spec.js --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG!
echo ====================================================================
echo.
pause
`;
      fs.writeFileSync(pageBatPath, pageBatContent, 'utf8');

      let pageMd = `# BÁO CÁO KIỂM THỬ TRANG: ${pageName.toUpperCase()}\n\n`;
      pageMd += `> Thời gian kiểm thử: **${timestamp}**\n`;
      pageMd += `> Tổng số kịch bản: **${list.length}** | `;
      const passedCount = list.filter(t => t.businessStatus === 'PASSED').length;
      const failedCount = list.length - passedCount;
      pageMd += `✅ LOGIC PASS: **${passedCount}** | ❌ LOGIC FAIL: **${failedCount}**\n\n`;

      // Bảng tổng hợp trạng thái kép cho từng TC
      pageMd += `## BẢNG ĐỐI CHIẾU TRẠNG THÁI TEST & LOGIC NGHIỆP VỤ\n\n`;
      pageMd += `| Mã TC | Tiêu đề Kịch bản | Trạng thái Test | Trạng thái Logic | Đánh giá Nghiệp vụ |\n`;
      pageMd += `| :--- | :--- | :---: | :---: | :--- |\n`;
      for (const tc of list) {
        const testBadge = tc.testStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
        const bizBadge = tc.businessStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
        pageMd += `| **${tc.tcId}** | ${tc.title} | ${testBadge} | ${bizBadge} | ${tc.businessNotes || '—'} |\n`;
      }
      pageMd += `\n---\n\n`;

      for (const tc of list) {
        const testBadge = tc.testStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
        const bizBadge = tc.businessStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
        pageMd += `### ${tc.tcId}: ${tc.title}\n\n`;
        pageMd += `* **Trạng thái thực thi Test (Kỹ thuật)**: ${testBadge} (Thời gian thực thi: \`${tc.duration}\`)\n`;
        pageMd += `* **Trạng thái Logic Nghiệp vụ (Business Output)**: ${bizBadge}\n`;
        pageMd += `* **Đánh giá tổng quát**: ${tc.businessNotes}\n`;
        pageMd += `* **Thư mục lưu trữ**: \`test-evidence/${pageName}/${tc.tcId}/\`\n\n`;

        // 🚨 NẾU TC FAIL: Hiển thị Khối Phân Tích Nguyên Nhân Thất Bại (Failure Analysis)
        if (tc.businessStatus === 'FAILED' || tc.testStatus === 'FAILED') {
          pageMd += `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)\n`;
          pageMd += `>\n`;
          pageMd += `> * **Vấn đề / Mã lỗi**: ${tc.failureAnalysis.issue || tc.businessNotes}\n`;
          if (tc.failureAnalysis.expected) {
            pageMd += `> * **Kỳ vọng nghiệp vụ (Expected Output)**: ${tc.failureAnalysis.expected}\n`;
          }
          if (tc.failureAnalysis.actual) {
            pageMd += `> * **Thực tế hệ thống (Actual Output)**: ${tc.failureAnalysis.actual}\n`;
          }
          if (tc.failureAnalysis.rootCause) {
            pageMd += `> * **Nguyên nhân cốt lõi (Root Cause)**: ${tc.failureAnalysis.rootCause}\n`;
          }
          if (tc.failureAnalysis.recommendation) {
            pageMd += `> * **Đề xuất khắc phục (Recommendation)**: ${tc.failureAnalysis.recommendation}\n`;
          }
          pageMd += `\n`;
        }

        if (tc.errors) {
          pageMd += `> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):\n`;
          pageMd += `\`\`\`\n${tc.errors}\n\`\`\`\n\n`;
        }

        // BẰNG CHỨNG HÌNH ẢNH STEP-BY-STEP
        pageMd += `#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):\n\n`;
        if (tc.stepScreenshots && tc.stepScreenshots.length > 0) {
          for (const s of tc.stepScreenshots) {
            const relToReport = s.relPath.replace(`${pageName}/`, '');
            pageMd += `##### 🔹 Bước ${s.step}: ${s.title}\n`;
            pageMd += `![Bước ${s.step}: ${s.title}](${relToReport})\n\n`;
          }
        } else {
          pageMd += `*(Không có ảnh chụp màn hình)*\n\n`;
        }

        // VIDEO VÀ TRACE
        pageMd += `#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):\n`;
        if (tc.attachments.videos.length > 0) {
          for (const v of tc.attachments.videos) {
            const relToReport = v.replace(`${pageName}/`, '');
            pageMd += `- **Video phiên chạy thực tế**: [${path.basename(v)}](${relToReport})\n`;
          }
        }
        if (tc.attachments.traces.length > 0) {
          for (const t of tc.attachments.traces) {
            const relToReport = t.replace(`${pageName}/`, '');
            pageMd += `- **Playwright Trace**: [${path.basename(t)}](${relToReport}) *(Mở bằng: \`npx playwright show-trace test-evidence/${t}\`)*\n`;
          }
        }
        pageMd += `\n---\n\n`;
      }

      fs.writeFileSync(path.join(pageDir, 'test-report.md'), pageMd, 'utf8');
    }

    // 2. Tạo báo cáo tổng hợp Master tại gốc: test-evidence/test-report.md
    let masterMd = `# BÁO CÁO KIỂM THỬ TỔNG HỢP E2E (MASTER TEST REPORT)\n\n`;
    masterMd += `> Thời gian kiểm thử: **${timestamp}**\n`;
    masterMd += `> Tổng số trang: **${Object.keys(this.pageResults).length}** | Tổng số kịch bản: **${this.allResults.length}**\n\n`;
    masterMd += `## 1. TỔNG QUAN THEO TỪNG TRANG / MENU\n\n`;
    masterMd += `| Trang / Menu | File Kịch Bản | Số Test Case | Trạng thái Logic | Báo cáo chi tiết |\n`;
    masterMd += `| :--- | :--- | :--- | :--- | :--- |\n`;

    for (const pageName of Object.keys(this.pageResults)) {
      const list = this.pageResults[pageName];
      const pCount = list.filter(t => t.businessStatus === 'PASSED').length;
      const fCount = list.length - pCount;
      const statusText = fCount === 0 ? '✅ 100% LOGIC PASS' : `❌ ${fCount} LOGIC FAIL`;
      masterMd += `| **${pageName}** | \`tests/${pageName}.spec.js\` | ${list.length} | ${statusText} | [Xem chi tiết](${pageName}/test-report.md) |\n`;
    }

    masterMd += `\n---\n\n`;
    masterMd += `## 2. CHI TIẾT TẤT CẢ TEST CASES\n\n`;

    for (const tc of this.allResults) {
      const testBadge = tc.testStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
      const bizBadge = tc.businessStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
      masterMd += `### [${tc.pageName}] ${tc.tcId}: ${tc.title}\n\n`;
      masterMd += `* **Trạng thái thực thi Test (Kỹ thuật)**: ${testBadge} (Thời gian thực thi: \`${tc.duration}\`)\n`;
      masterMd += `* **Trạng thái Logic Nghiệp vụ (Business Output)**: ${bizBadge}\n`;
      masterMd += `* **Đánh giá chi tiết**: ${tc.businessNotes}\n`;
      masterMd += `* **Thư mục bằng chứng**: [\`test-evidence/${tc.pageName}/${tc.tcId}/\`](file:///${path.resolve(this.outputDir, tc.pageName, tc.tcId).replace(/\\/g, '/')})\n\n`;

      if (tc.businessStatus === 'FAILED' || tc.testStatus === 'FAILED') {
        masterMd += `> [!CAUTION] 🚨 PHÂN TÍCH NGUYÊN NHÂN THẤT BẠI (FAILURE ANALYSIS)\n`;
        masterMd += `>\n`;
        masterMd += `> * **Vấn đề / Mã lỗi**: ${tc.failureAnalysis.issue || tc.businessNotes}\n`;
        if (tc.failureAnalysis.expected) {
          masterMd += `> * **Kỳ vọng nghiệp vụ (Expected Output)**: ${tc.failureAnalysis.expected}\n`;
        }
        if (tc.failureAnalysis.actual) {
          masterMd += `> * **Thực tế hệ thống (Actual Output)**: ${tc.failureAnalysis.actual}\n`;
        }
        if (tc.failureAnalysis.rootCause) {
          masterMd += `> * **Nguyên nhân cốt lõi (Root Cause)**: ${tc.failureAnalysis.rootCause}\n`;
        }
        if (tc.failureAnalysis.recommendation) {
          masterMd += `> * **Đề xuất khắc phục (Recommendation)**: ${tc.failureAnalysis.recommendation}\n`;
        }
        masterMd += `\n`;
      }

      if (tc.errors) {
        masterMd += `> [!WARNING] Lỗi Kỹ Thuật:\n\`\`\`\n${tc.errors}\n\`\`\`\n\n`;
      }

      masterMd += `#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):\n\n`;
      if (tc.stepScreenshots && tc.stepScreenshots.length > 0) {
        for (const s of tc.stepScreenshots) {
          masterMd += `##### 🔹 Bước ${s.step}: ${s.title}\n`;
          masterMd += `![Bước ${s.step}: ${s.title}](${s.relPath})\n\n`;
        }
      }

      masterMd += `#### 🎥 Video & Dấu vết kiểm thử (Video & Trace):\n`;
      if (tc.attachments.videos.length > 0) {
        for (const v of tc.attachments.videos) {
          masterMd += `- **Video**: [${path.basename(v)}](${v})\n`;
        }
      }
      if (tc.attachments.traces.length > 0) {
        for (const t of tc.attachments.traces) {
          masterMd += `- **Trace**: [${path.basename(t)}](${t})\n`;
        }
      }
      masterMd += `\n---\n\n`;
    }

    fs.writeFileSync(path.join(this.outputDir, 'test-report.md'), masterMd, 'utf8');

    // 3. Ghi master results.json
    fs.writeFileSync(path.join(this.outputDir, 'results.json'), JSON.stringify({
      status: result.status,
      timestamp,
      totalTests: this.allResults.length,
      pages: this.pageResults
    }, null, 2), 'utf8');

    console.log(`\n📄 [REPORTER]: Đã xuất cấu trúc báo cáo phân cấp chuyên nghiệp tại: ${this.outputDir}`);
  }
}

module.exports = HierarchicalMarkdownReporter;
