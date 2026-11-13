const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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

  onTestBegin(test, result) {
    // Tự động dọn sạch thư mục screenshots cũ của TC trước khi chạy lượt mới
    const specFilePath = test.location ? test.location.file : '';
    let pageName = 'common';
    if (specFilePath) {
      pageName = path.basename(specFilePath)
        .replace(/\.spec\.[jt]s$/, '')
        .replace(/\.[jt]s$/, '');
    }
    const tcMatch = test.title.match(/(?:TC|FLOW|E2E)-(\d+)/i);
    const tcId = tcMatch ? tcMatch[0].toUpperCase() : null;
    if (tcId) {
      const screenshotsDir = path.join(this.outputDir, pageName, tcId, 'screenshots');
      if (fs.existsSync(screenshotsDir)) {
        try {
          const files = fs.readdirSync(screenshotsDir);
          for (const f of files) {
            if (f.endsWith('.png')) {
              fs.unlinkSync(path.join(screenshotsDir, f));
            }
          }
        } catch (_) {}
      }
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

    // 2. Xác định mã TC (ví dụ TC-01, TC-02, FLOW-01) từ tiêu đề test
    const tcMatch = test.title.match(/(?:TC|FLOW|E2E)-(\d+)/i);
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
          stepTitle = stepTitle.replace(/^(?:TC|FLOW|E2E)-\d+[-_]step\d+[-_]?/i, '').replace(/[-_]+/g, ' ');
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

    // 🛑 BỘ LỌC CHỐNG TRÙNG LẶP ẢNH THÔNG MINH (SMART IMAGE DEDUPLICATION)
    // Nếu ảnh bước sau giống hệt 100% (cùng hash MD5) với ảnh bước trước:
    // Đánh dấu isDuplicate = true và xoá file trùng để tránh hiển thị 1 ảnh nhiều lần liên tiếp
    let prevHash = null;
    let prevStepNum = null;
    const deduplicatedScreenshots = [];

    for (const item of stepScreenshots) {
      const fullPath = path.join(screenshotsDir, item.fileName);
      let currentHash = null;
      try {
        if (fs.existsSync(fullPath)) {
          const buf = fs.readFileSync(fullPath);
          currentHash = crypto.createHash('md5').update(buf).digest('hex');
        }
      } catch (_) {}

      if (currentHash && currentHash === prevHash) {
        // Ảnh trùng hệt 100% với bước trước!
        try { fs.unlinkSync(fullPath); } catch (_) {}
        deduplicatedScreenshots.push({
          ...item,
          isDuplicate: true,
          duplicateOfStep: prevStepNum
        });
      } else {
        prevHash = currentHash;
        prevStepNum = item.step;
        deduplicatedScreenshots.push(item);
      }
    }

    // Nếu có ảnh chụp theo bước thì xóa bỏ test-finished thừa để không làm loãng báo cáo
    if (deduplicatedScreenshots.length > 0) {
      for (const fb of fallbackScreenshots) {
        try { fs.unlinkSync(path.join(screenshotsDir, fb.fileName)); } catch (_) {}
      }
    }

    const finalScreenshots = deduplicatedScreenshots.length > 0 ? deduplicatedScreenshots : fallbackScreenshots;

    // 7. Đánh giá Trạng thái kép: Kỹ thuật (Playwright) và Logic Nghiệp vụ
    const bizAnn = (test.annotations || []).find(a => a.type === 'business_status');
    const defectAnn = (test.annotations || []).find(a => a.type === 'defect_evidence');
    const legacyAnalysisAnn = (test.annotations || []).find(a => a.type === 'business_analysis');

    let businessStatus = 'PASSED';
    let businessNotes = 'Đạt yêu cầu logic nghiệp vụ mong đợi';
    let defectEvidence = null;

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

    // Trích xuất bằng chứng lỗi khách quan (DEFECT EVIDENCE - FACTS ONLY)
    if (defectAnn && defectAnn.description) {
      try {
        defectEvidence = JSON.parse(defectAnn.description);
      } catch (_) {
        defectEvidence = { issue: defectAnn.description };
      }
    } else if (legacyAnalysisAnn && legacyAnalysisAnn.description) {
      try {
        defectEvidence = JSON.parse(legacyAnalysisAnn.description);
      } catch (_) {
        defectEvidence = { issue: legacyAnalysisAnn.description };
      }
    } else if (businessStatus === 'FAILED') {
      const expMatch = businessNotes.match(/Kỳ vọng[:\s]+([^,)]+)/i);
      const actMatch = businessNotes.match(/Thực tế[:\s]+([^,)]+)/i);
      defectEvidence = {
        issue: businessNotes,
        expected: expMatch ? expMatch[1].trim() : 'Theo đặc tả chuẩn của hệ thống',
        actual: actMatch ? actMatch[1].trim() : 'Thực tế phát sinh lỗi hoặc không đạt điều kiện kiểm tra'
      };
    }

    let cleanTitle = test.title.replace(new RegExp(`^${tcId}[:\\s-]*`, 'i'), '').trim();

    const tcResult = {
      tcId,
      pageName,
      title: cleanTitle,
      testStatus: status,
      businessStatus: businessStatus,
      businessNotes: businessNotes,
      defectEvidence,
      failureAnalysis: defectEvidence || {},
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
      const pageDir = path.join(this.outputDir, pageName);

      // Thu thập toàn bộ kết quả của trang (gộp giữa phiên chạy hiện tại và các TC đã chạy trước đó trên đĩa)
      const mergedMap = new Map();
      if (fs.existsSync(pageDir)) {
        const subDirs = fs.readdirSync(pageDir, { withFileTypes: true })
          .filter(d => d.isDirectory() && (d.name.startsWith('TC-') || d.name.startsWith('FLOW-')));
        for (const sd of subDirs) {
          const resPath = path.join(pageDir, sd.name, 'results.json');
          if (fs.existsSync(resPath)) {
            try {
              const prevData = JSON.parse(fs.readFileSync(resPath, 'utf8'));
              mergedMap.set(prevData.tcId, prevData);
            } catch (_) {}
          }
        }
      }
      for (const curTc of (this.pageResults[pageName] || [])) {
        mergedMap.set(curTc.tcId, curTc);
      }
      const list = Array.from(mergedMap.values()).sort((a, b) => a.tcId.localeCompare(b.tcId, undefined, { numeric: true }));

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

        // 🚨 NẾU TC FAIL: Hiển thị Khối Bằng Chứng Sai Khác Thực Tế (DEFECT EVIDENCE - FACTS ONLY)
        if (tc.businessStatus === 'FAILED' || tc.testStatus === 'FAILED') {
          const evidenceObj = tc.defectEvidence || tc.failureAnalysis || {};
          pageMd += `> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)\n`;
          pageMd += `>\n`;
          pageMd += `> * **Vấn đề ghi nhận**: ${evidenceObj.issue || tc.businessNotes}\n`;
          if (evidenceObj.expected) {
            pageMd += `> * **Kỳ vọng nghiệp vụ (Expected Output)**: ${evidenceObj.expected}\n`;
          }
          if (evidenceObj.actual) {
            pageMd += `> * **Thực tế hệ thống (Actual Output)**: ${evidenceObj.actual}\n`;
          }
          if (evidenceObj.evidence) {
            const evStr = typeof evidenceObj.evidence === 'object' ? JSON.stringify(evidenceObj.evidence, null, 2) : evidenceObj.evidence;
            pageMd += `> * **Dữ liệu kỹ thuật liên quan (Technical Evidence)**:\n\`\`\`json\n${evStr}\n\`\`\`\n`;
          }
          pageMd += `>\n`;
          pageMd += `> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.\n`;
          pageMd += `\n`;
        }

        if (tc.errors) {
          pageMd += `> [!WARNING] Lỗi Kỹ Thuật (System/Playwright Error):\n`;
          pageMd += `\`\`\`\n${tc.errors}\n\`\`\`\n\n`;
        }

        // BẰNG CHỨNG HÌNH ẢNH STEP-BY-STEP (GOM NHÓM THEO BƯỚC)
        pageMd += `#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):\n\n`;
        if (tc.stepScreenshots && tc.stepScreenshots.length > 0) {
          // Gom nhóm ảnh theo Bước (Group by Step)
          const stepGroups = new Map();
          for (const s of tc.stepScreenshots) {
            if (!stepGroups.has(s.step)) {
              stepGroups.set(s.step, { step: s.step, title: s.title, list: [] });
            }
            stepGroups.get(s.step).list.push(s);
          }
          const sortedSteps = Array.from(stepGroups.values()).sort((a, b) => a.step - b.step);
          for (const grp of sortedSteps) {
            pageMd += `##### 🔹 Bước ${grp.step}: ${grp.title}\n`;
            for (const item of grp.list) {
              if (item.isDuplicate) {
                pageMd += `> *(Giao diện giữ nguyên, không phát sinh thay đổi so với Bước ${item.duplicateOfStep})*\n\n`;
              } else {
                const relToReport = item.relPath.replace(`${pageName}/`, '');
                pageMd += `![Bước ${grp.step}: ${item.title}](${relToReport})\n\n`;
              }
            }
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
    // Thu thập toàn bộ các trang và kịch bản có sẵn trong test-evidence để báo cáo master luôn đầy đủ
    const allPageSummaries = {};
    const masterTCList = [];
    if (fs.existsSync(this.outputDir)) {
      const pageDirs = fs.readdirSync(this.outputDir, { withFileTypes: true })
        .filter(d => d.isDirectory() && !d.name.startsWith('.') && d.name !== 'node_modules');
      for (const pd of pageDirs) {
        const pDir = path.join(this.outputDir, pd.name);
        const subDirs = fs.readdirSync(pDir, { withFileTypes: true })
          .filter(d => d.isDirectory() && (d.name.startsWith('TC-') || d.name.startsWith('FLOW-')));
        if (subDirs.length > 0) {
          const tcList = [];
          for (const sd of subDirs) {
            const resPath = path.join(pDir, sd.name, 'results.json');
            if (fs.existsSync(resPath)) {
              try {
                const tcData = JSON.parse(fs.readFileSync(resPath, 'utf8'));
                tcList.push(tcData);
                masterTCList.push(tcData);
              } catch (_) {}
            }
          }
          if (tcList.length > 0) {
            allPageSummaries[pd.name] = tcList.sort((a, b) => a.tcId.localeCompare(b.tcId, undefined, { numeric: true }));
          }
        }
      }
    }

    let masterMd = `# BÁO CÁO KIỂM THỬ TỔNG HỢP E2E (MASTER TEST REPORT)\n\n`;
    masterMd += `> Thời gian kiểm thử: **${timestamp}**\n`;
    masterMd += `> Tổng số trang: **${Object.keys(allPageSummaries).length}** | Tổng số kịch bản: **${masterTCList.length}**\n\n`;
    masterMd += `## 1. TỔNG QUAN THEO TỪNG TRANG / MENU\n\n`;
    masterMd += `| Trang / Menu | File Kịch Bản | Số Test Case | Trạng thái Logic | Báo cáo chi tiết |\n`;
    masterMd += `| :--- | :--- | :--- | :--- | :--- |\n`;

    for (const pageName of Object.keys(allPageSummaries).sort()) {
      const list = allPageSummaries[pageName];
      const pCount = list.filter(t => t.businessStatus === 'PASSED').length;
      const fCount = list.length - pCount;
      const statusText = fCount === 0 ? '✅ 100% LOGIC PASS' : `❌ ${fCount} LOGIC FAIL`;
      masterMd += `| **${pageName}** | \`tests/${pageName}.spec.js\` | ${list.length} | ${statusText} | [Xem chi tiết](${pageName}/test-report.md) |\n`;
    }

    masterMd += `\n---\n\n`;
    masterMd += `## 2. CHI TIẾT TẤT CẢ TEST CASES\n\n`;

    for (const tc of masterTCList) {
      const testBadge = tc.testStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
      const bizBadge = tc.businessStatus === 'PASSED' ? '✅ PASS' : '❌ FAIL';
      masterMd += `### [${tc.pageName}] ${tc.tcId}: ${tc.title}\n\n`;
      masterMd += `* **Trạng thái thực thi Test (Kỹ thuật)**: ${testBadge} (Thời gian thực thi: \`${tc.duration}\`)\n`;
      masterMd += `* **Trạng thái Logic Nghiệp vụ (Business Output)**: ${bizBadge}\n`;
      masterMd += `* **Đánh giá chi tiết**: ${tc.businessNotes}\n`;
      masterMd += `* **Thư mục bằng chứng**: [\`test-evidence/${tc.pageName}/${tc.tcId}/\`](file:///${path.resolve(this.outputDir, tc.pageName, tc.tcId).replace(/\\/g, '/')})\n\n`;

      if (tc.businessStatus === 'FAILED' || tc.testStatus === 'FAILED') {
        const evidenceObj = tc.defectEvidence || tc.failureAnalysis || {};
        masterMd += `> [!CAUTION] 🚨 THÔNG TIN LỖI PHÁT HIỆN TỪ THỰC THI (DEFECT EVIDENCE - FACTS ONLY)\n`;
        masterMd += `>\n`;
        masterMd += `> * **Vấn đề ghi nhận**: ${evidenceObj.issue || tc.businessNotes}\n`;
        if (evidenceObj.expected) {
          masterMd += `> * **Kỳ vọng nghiệp vụ (Expected Output)**: ${evidenceObj.expected}\n`;
        }
        if (evidenceObj.actual) {
          masterMd += `> * **Thực tế hệ thống (Actual Output)**: ${evidenceObj.actual}\n`;
        }
        if (evidenceObj.evidence) {
          const evStr = typeof evidenceObj.evidence === 'object' ? JSON.stringify(evidenceObj.evidence, null, 2) : evidenceObj.evidence;
          masterMd += `> * **Dữ liệu kỹ thuật liên quan (Technical Evidence)**:\n\`\`\`json\n${evStr}\n\`\`\`\n`;
        }
        masterMd += `>\n`;
        masterMd += `> 📌 **Lưu ý**: Kịch bản Test chỉ ghi nhận dữ liệu thực tế và sai khác. Phân tích nguyên nhân gốc (Root Cause) và giải pháp khắc phục sẽ do AI Agent điều tra và brainstorm trực tiếp từ Database & Source Code khi người dùng yêu cầu.\n`;
        masterMd += `\n`;
      }

      if (tc.errors) {
        masterMd += `> [!WARNING] Lỗi Kỹ Thuật:\n\`\`\`\n${tc.errors}\n\`\`\`\n\n`;
      }

      masterMd += `#### 📸 Bằng chứng trực quan từng bước (Step-by-Step Evidence):\n\n`;
      if (tc.stepScreenshots && tc.stepScreenshots.length > 0) {
        const stepGroups = new Map();
        for (const s of tc.stepScreenshots) {
          if (!stepGroups.has(s.step)) {
            stepGroups.set(s.step, { step: s.step, title: s.title, list: [] });
          }
          stepGroups.get(s.step).list.push(s);
        }
        const sortedSteps = Array.from(stepGroups.values()).sort((a, b) => a.step - b.step);
        for (const grp of sortedSteps) {
          masterMd += `##### 🔹 Bước ${grp.step}: ${grp.title}\n`;
          for (const item of grp.list) {
            if (item.isDuplicate) {
              masterMd += `> *(Giao diện giữ nguyên, không phát sinh thay đổi so với Bước ${item.duplicateOfStep})*\n\n`;
            } else {
              masterMd += `![Bước ${grp.step}: ${item.title}](${item.relPath})\n\n`;
            }
          }
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

    try {
      fs.writeFileSync(path.join(this.outputDir, 'test-report.md'), masterMd, 'utf8');
    } catch (e) {
      console.warn('⚠️ [REPORTER]: Không thể ghi đè test-report.md do file đang được mở hoặc khóa:', e.message);
    }

    // 3. Ghi master results.json
    try {
      fs.writeFileSync(path.join(this.outputDir, 'results.json'), JSON.stringify({
        status: result.status,
        timestamp,
        totalTests: this.allResults.length,
        pages: this.pageResults
      }, null, 2), 'utf8');
    } catch (e) {
      console.warn('⚠️ [REPORTER]: Không thể ghi đè results.json:', e.message);
    }

    console.log(`\n📄 [REPORTER]: Đã xuất cấu trúc báo cáo phân cấp chuyên nghiệp tại: ${this.outputDir}`);
  }
}

module.exports = HierarchicalMarkdownReporter;
