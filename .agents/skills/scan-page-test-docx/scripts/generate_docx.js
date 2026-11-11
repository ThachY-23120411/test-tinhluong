const fs = require('fs');
const path = require('path');
const docx = require('docx');

const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  WidthType,
  AlignmentType,
  HeadingLevel,
  BorderStyle,
  Header,
  Footer,
  PageNumber
} = docx;

// Bảng màu thiết kế chuyên nghiệp
const COLORS = {
  PRIMARY: '1A365D',     // Xanh Navy đậm
  SECONDARY: '2B6CB0',   // Xanh dương doanh nghiệp
  HEADER_BG: '2B6CB0',   // Nền tiêu đề bảng
  ZEBRA_BG: 'F7FAFC',    // Nền dòng chẵn
  HIGHLIGHT_BG: 'EDF2F7',// Nền khối lưu ý
  TEXT_MAIN: '2D3748',   // Chữ chính
  TEXT_MUTED: '718096',  // Chữ phụ
  BORDER: 'CBD5E0',      // Viền bảng
  PASS: '22543D',        // Xanh lá thành công
  PASS_BG: 'C6F6D5',
  FAIL: '742A2A',        // Đỏ cảnh báo
  FAIL_BG: 'FED7D7'
};

const CELL_BORDER = {
  top: { style: BorderStyle.SINGLE, size: 1, color: COLORS.BORDER },
  bottom: { style: BorderStyle.SINGLE, size: 1, color: COLORS.BORDER },
  left: { style: BorderStyle.SINGLE, size: 1, color: COLORS.BORDER },
  right: { style: BorderStyle.SINGLE, size: 1, color: COLORS.BORDER }
};

/**
 * Tạo ô tiêu đề bảng chuẩn
 */
function createHeaderCell(text, widthPercent) {
  return new TableCell({
    width: { size: widthPercent, type: WidthType.PERCENTAGE },
    shading: { fill: COLORS.HEADER_BG },
    margins: { top: 120, bottom: 120, left: 140, right: 140 },
    borders: CELL_BORDER,
    children: [
      new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [
          new TextRun({ text, bold: true, color: 'FFFFFF', size: 20, font: 'Calibri' })
        ]
      })
    ]
  });
}

/**
 * Tạo ô dữ liệu thường trong bảng
 */
function createDataCell(text, widthPercent, options = {}) {
  const isCentered = options.align === 'center';
  const isBold = !!options.bold;
  const bgColor = options.bg || (options.isZebra ? COLORS.ZEBRA_BG : 'FFFFFF');

  return new TableCell({
    width: { size: widthPercent, type: WidthType.PERCENTAGE },
    shading: { fill: bgColor },
    margins: { top: 100, bottom: 100, left: 140, right: 140 },
    borders: CELL_BORDER,
    children: [
      new Paragraph({
        alignment: isCentered ? AlignmentType.CENTER : AlignmentType.LEFT,
        children: [
          new TextRun({
            text: String(text || '-'),
            bold: isBold,
            color: options.color || COLORS.TEXT_MAIN,
            size: 19,
            font: 'Calibri'
          })
        ]
      })
    ]
  });
}

/**
 * Tạo đoạn văn bản Heading đẹp
 */
function createHeading(text, level) {
  return new Paragraph({
    text: text,
    heading: level,
    spacing: { before: 280, after: 120 }
  });
}

/**
 * Tạo bảng kịch bản test chi tiết từng bước
 */
function createTestCaseBlock(tc) {
  const rows = [
    // Header dòng 1: Mã TC & Tiêu đề
    new TableRow({
      children: [
        new TableCell({
          width: { size: 25, type: WidthType.PERCENTAGE },
          shading: { fill: COLORS.PRIMARY },
          margins: { top: 100, bottom: 100, left: 140, right: 140 },
          borders: CELL_BORDER,
          children: [
            new Paragraph({
              children: [new TextRun({ text: tc.id, bold: true, color: 'FFFFFF', size: 20 })]
            })
          ]
        }),
        new TableCell({
          width: { size: 75, type: WidthType.PERCENTAGE },
          shading: { fill: COLORS.HIGHLIGHT_BG },
          margins: { top: 100, bottom: 100, left: 140, right: 140 },
          borders: CELL_BORDER,
          children: [
            new Paragraph({
              children: [new TextRun({ text: tc.title, bold: true, color: COLORS.PRIMARY, size: 20 })]
            })
          ]
        })
      ]
    }),
    // Dòng 2: Mục đích & Tiền đề
    new TableRow({
      children: [
        createDataCell('Mục đích & Tiền đề', 25, { bold: true, bg: COLORS.ZEBRA_BG }),
        createDataCell(`Mục đích: ${tc.objective || '-'}\nTiền đề: ${tc.precondition || 'Không có'}`, 75)
      ]
    }),
    // Dòng 3: Dữ liệu kiểm thử
    new TableRow({
      children: [
        createDataCell('Dữ liệu kiểm thử', 25, { bold: true, bg: COLORS.ZEBRA_BG }),
        createDataCell(tc.testData || 'Sử dụng dữ liệu thực tế trên hệ thống', 75)
      ]
    }),
    // Dòng 4: Các bước thực hiện
    new TableRow({
      children: [
        createDataCell('Các bước thực hiện', 25, { bold: true, bg: COLORS.ZEBRA_BG }),
        createDataCell(
          tc.steps
            ? tc.steps.map((s, idx) => {
                const cleanStep = s.trim();
                return /^bước\s*\d+\s*:/i.test(cleanStep) ? cleanStep : `Bước ${idx + 1}: ${cleanStep}`;
              }).join('\n')
            : '-',
          75
        )
      ]
    }),
    // Dòng 5: Kết quả mong đợi (Expected)
    new TableRow({
      children: [
        createDataCell('Kỳ vọng nghiệp vụ', 25, { bold: true, bg: COLORS.ZEBRA_BG, color: COLORS.PASS }),
        createDataCell(tc.expected || '-', 75, { bold: true, color: COLORS.PASS })
      ]
    })
  ];

  // Dòng 6: Truy vấn CSDL đối soát (DB Verification Query) nếu có
  if (tc.dbQuery) {
    const queryText = typeof tc.dbQuery === 'string'
      ? tc.dbQuery
      : `Câu lệnh SQL (Read-only):\n${tc.dbQuery.sql || '-'}\n\nKết quả CSDL xác thực: ${tc.dbQuery.expectedResult || '-'}`;
    rows.push(
      new TableRow({
        children: [
          createDataCell('🗄️ Truy vấn CSDL đối soát', 25, { bold: true, bg: 'F0FFF4', color: '22543D' }),
          createDataCell(queryText, 75, { bg: 'F7FAFC', color: '1A365D' })
        ]
      })
    );
  }

  // Nếu có thông tin đối soát downstream
  if (tc.downstream) {
    rows.push(
      new TableRow({
        children: [
          createDataCell('🔍 Đối soát Downstream', 25, { bold: true, bg: 'EBF8FF', color: '2B6CB0' }),
          createDataCell(
            `Màn hình đối soát: ${tc.downstream.targetMenu || '-'}\n` +
            `Tài khoản / Vai trò: ${tc.downstream.role || '-'}\n` +
            `Dữ liệu cần kiểm chứng: ${tc.downstream.verification || '-'}`,
            75,
            { bg: 'F7FAFC' }
          )
        ]
      })
    );
  }

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: rows
  });
}

/**
 * Hàm sinh file DOCX hoàn chỉnh từ dữ liệu đặc tả kịch bản
 */
async function generateTestSpecDocx(data, outputPath) {
  const pageName = data.pageName || 'Chưa đặt tên';
  const systemName = data.systemName || 'Paradise HRM / CRM';
  const createdDate = data.createdDate || new Date().toLocaleDateString('vi-VN');

  const children = [];

  // ==========================================================================
  // KHỐI 1: TRANG TIÊU ĐỀ BÌA CHÍNH (TITLE PAGE / COVER)
  // ==========================================================================
  children.push(
    new Paragraph({ spacing: { before: 800, after: 200 } }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [
        new TextRun({
          text: systemName.toUpperCase(),
          bold: true,
          color: COLORS.SECONDARY,
          size: 26,
          font: 'Calibri'
        })
      ]
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [
        new TextRun({
          text: 'TÀI LIỆU ĐẶC TẢ KỊCH BẢN KIỂM THỬ NGHIỆP VỤ',
          bold: true,
          color: COLORS.PRIMARY,
          size: 40,
          font: 'Calibri'
        })
      ],
      spacing: { before: 150, after: 150 }
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [
        new TextRun({
          text: `MÀN HÌNH / PHÂN HỆ: ${pageName.toUpperCase()}`,
          bold: true,
          color: COLORS.SECONDARY,
          size: 24,
          font: 'Calibri'
        })
      ],
      spacing: { after: 600 }
    })
  );

  // Bảng thông tin siêu dữ liệu (Metadata Table)
  const metaTable = new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          createDataCell('Hệ thống mục tiêu', 30, { bold: true, bg: COLORS.ZEBRA_BG }),
          createDataCell(systemName, 70)
        ]
      }),
      new TableRow({
        children: [
          createDataCell('Phân hệ / Tên Menu', 30, { bold: true, bg: COLORS.ZEBRA_BG }),
          createDataCell(`${pageName} (${data.menuUrl || '-'})`, 70)
        ]
      }),
      new TableRow({
        children: [
          createDataCell('Ngày khảo sát & xuất bản', 30, { bold: true, bg: COLORS.ZEBRA_BG }),
          createDataCell(createdDate, 70)
        ]
      }),
      new TableRow({
        children: [
          createDataCell('Phiên bản tài liệu', 30, { bold: true, bg: COLORS.ZEBRA_BG }),
          createDataCell('v1.0 (Phân tích tự động từ DOM, API & DB Ast)', 70)
        ]
      }),
      new TableRow({
        children: [
          createDataCell('Tổng số kịch bản kiểm thử', 30, { bold: true, bg: COLORS.ZEBRA_BG }),
          createDataCell(
            `Tổng: ${((data.controlCases || []).length + (data.crudCases || []).length + (data.flowCases || []).length)} TCs ` +
            `(${data.controlCases?.length || 0} Controls + ${data.crudCases?.length || 0} CRUD + ${data.flowCases?.length || 0} Downstream)`,
            70,
            { bold: true, color: COLORS.PRIMARY }
          )
        ]
      })
    ]
  });
  children.push(metaTable);
  children.push(new Paragraph({ pageBreakBefore: true }));

  // ==========================================================================
  // KHỐI 2: TỔNG QUAN VÀ BẢNG KIỂM KÊ 100% CONTROLS (FULL INVENTORY)
  // ==========================================================================
  children.push(
    createHeading('1. BẢNG KIỂM KÊ 100% CONTROLS, TOOLBAR VÀ BỘ LỌC', HeadingLevel.HEADING_1),
    new Paragraph({
      children: [
        new TextRun({
          text: 'Bảng kiểm kê toàn diện mọi thành phần giao diện được bóc tách trực tiếp từ cây DOM thực tế của màn hình, đảm bảo không bỏ sót bất kỳ nút bấm, bộ lọc hay ô nhập liệu nào:',
          color: COLORS.TEXT_MAIN,
          size: 20
        })
      ],
      spacing: { after: 150 }
    })
  );

  const inventoryRows = [
    new TableRow({
      children: [
        createHeaderCell('STT', 8),
        createHeaderCell('Tên Control / Button', 24),
        createHeaderCell('Nhóm chức năng', 18),
        createHeaderCell('Vị trí / Selector', 22),
        createHeaderCell('Hành động kiểm thử', 28)
      ]
    })
  ];

  (data.inventory || []).forEach((item, idx) => {
    inventoryRows.push(
      new TableRow({
        children: [
          createDataCell(idx + 1, 8, { align: 'center', isZebra: idx % 2 === 1 }),
          createDataCell(item.name, 24, { bold: true, isZebra: idx % 2 === 1 }),
          createDataCell(item.group, 18, { isZebra: idx % 2 === 1 }),
          createDataCell(item.selector || item.location, 22, { isZebra: idx % 2 === 1, color: COLORS.TEXT_MUTED }),
          createDataCell(item.action, 28, { isZebra: idx % 2 === 1 })
        ]
      })
    );
  });

  children.push(new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: inventoryRows }));
  children.push(new Paragraph({ spacing: { before: 200 } }));

  // ==========================================================================
  // KHỐI 3: KỊCH BẢN KIỂM THỬ TỪNG CONTROL, FILTER, TOOLBAR
  // ==========================================================================
  children.push(
    createHeading('2. KỊCH BẢN KIỂM THỬ GIAO DIỆN & CONTROLS (UI & UTILITY CONTROLS)', HeadingLevel.HEADING_1),
    new Paragraph({
      children: [
        new TextRun({
          text: 'Các kịch bản kiểm thử thẩm định tương tác trên Toolbar, Chip lọc trạng thái, Cặp ngày, Ô tìm kiếm và Bảng dữ liệu DataGrid:',
          color: COLORS.TEXT_MAIN,
          size: 20
        })
      ],
      spacing: { after: 150 }
    })
  );

  (data.controlCases || []).forEach(tc => {
    children.push(createTestCaseBlock(tc));
    children.push(new Paragraph({ spacing: { before: 150 } }));
  });

  // ==========================================================================
  // KHỐI 4: KỊCH BẢN KIỂM THỬ NGHIỆP VỤ CRUD CỐT LÕI
  // ==========================================================================
  children.push(
    new Paragraph({ pageBreakBefore: true }),
    createHeading('3. KỊCH BẢN KIỂM THỬ NGHIỆP VỤ CRUD CỐT LÕI (CORE BUSINESS FLOWS)', HeadingLevel.HEADING_1),
    new Paragraph({
      children: [
        new TextRun({
          text: 'Bộ kịch bản kiểm thử quy trình nghiệp vụ đầy đủ: Thêm mới bản ghi, Xem chi tiết, Cập nhật thông tin và Xóa/Chặn xóa:',
          color: COLORS.TEXT_MAIN,
          size: 20
        })
      ],
      spacing: { after: 150 }
    })
  );

  (data.crudCases || []).forEach(tc => {
    children.push(createTestCaseBlock(tc));
    children.push(new Paragraph({ spacing: { before: 150 } }));
  });

  // ==========================================================================
  // KHỐI 5: QUY TRÌNH NGHIỆP VỤ & MA TRẬN ĐỐI SOÁT DOWNSTREAM (RIPPLE EFFECT)
  // ==========================================================================
  children.push(
    new Paragraph({ pageBreakBefore: true }),
    createHeading('4. MA TRẬN ĐỐI SOÁT LIÊN MÀN HÌNH (CROSS-SCREEN DOWNSTREAM VERIFICATION)', HeadingLevel.HEADING_1),
    new Paragraph({
      children: [
        new TextRun({
          text: 'Phân tích "Hiệu ứng gợn sóng" (Ripple Effect): Khi một hành động Tạo/Sửa/Xóa diễn ra tại trang nguồn, dữ liệu được ghi vào CSDL. Bảng dưới đây truy vết toàn bộ các Stored Procedures, API, Màn hình đích và Vai trò người dùng chịu ảnh hưởng trực tiếp để kiểm chứng đối soát chéo:',
          color: COLORS.TEXT_MAIN,
          size: 20
        })
      ],
      spacing: { after: 150 }
    })
  );

  // Bảng Ma trận đối soát Downstream
  const downstreamRows = [
    new TableRow({
      children: [
        createHeaderCell('Hành động nguồn', 16),
        createHeaderCell('Bảng CSDL tác động', 18),
        createHeaderCell('API / SP Đọc dữ liệu', 22),
        createHeaderCell('Màn hình Đích đối soát', 22),
        createHeaderCell('Vai trò kiểm chứng', 22)
      ]
    })
  ];

  (data.downstreamMatrix || []).forEach((row, idx) => {
    downstreamRows.push(
      new TableRow({
        children: [
          createDataCell(row.sourceAction, 16, { bold: true, isZebra: idx % 2 === 1 }),
          createDataCell(row.targetTable, 18, { isZebra: idx % 2 === 1, color: COLORS.SECONDARY }),
          createDataCell(row.readApis, 22, { isZebra: idx % 2 === 1 }),
          createDataCell(row.targetScreens, 22, { bold: true, isZebra: idx % 2 === 1, color: COLORS.PRIMARY }),
          createDataCell(row.roles, 22, { isZebra: idx % 2 === 1 })
        ]
      })
    );
  });

  children.push(new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: downstreamRows }));
  children.push(new Paragraph({ spacing: { before: 200 } }));

  // Các test case đối soát liên màn hình chi tiết
  (data.flowCases || []).forEach(tc => {
    children.push(createTestCaseBlock(tc));
    children.push(new Paragraph({ spacing: { before: 150 } }));
  });

  // ==========================================================================
  // KHỐI 6: XUẤT TÀI LIỆU VỚI HEADER VÀ FOOTER
  // ==========================================================================
  const doc = new Document({
    styles: {
      default: {
        document: {
          run: { font: 'Calibri', size: 20, color: COLORS.TEXT_MAIN }
        }
      }
    },
    sections: [
      {
        properties: {
          page: {
            margin: { top: 1200, bottom: 1200, left: 1200, right: 1200 }
          }
        },
        headers: {
          default: new Header({
            children: [
              new Paragraph({
                alignment: AlignmentType.RIGHT,
                children: [
                  new TextRun({
                    text: `${systemName} — Đặc tả kịch bản kiểm thử: ${pageName}`,
                    italics: true,
                    size: 16,
                    color: COLORS.TEXT_MUTED
                  })
                ]
              })
            ]
          })
        },
        footers: {
          default: new Footer({
            children: [
              new Paragraph({
                alignment: AlignmentType.CENTER,
                children: [
                  new TextRun({ text: 'Trang ', size: 18, color: COLORS.TEXT_MUTED }),
                  new TextRun({ children: [PageNumber.CURRENT], size: 18, color: COLORS.TEXT_MUTED }),
                  new TextRun({ text: ' / ', size: 18, color: COLORS.TEXT_MUTED }),
                  new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 18, color: COLORS.TEXT_MUTED })
                ]
              })
            ]
          })
        },
        children: children
      }
    ]
  });

  // Đảm bảo thư mục đầu ra tồn tại
  const outDir = path.dirname(outputPath);
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outputPath, buffer);
  console.log(`✅ [DOCX GENERATOR]: Đã xuất thành công file Word tại: ${outputPath} (${buffer.length} bytes)`);
  return outputPath;
}

module.exports = { generateTestSpecDocx };

// Cho phép chạy trực tiếp từ dòng lệnh: node generate_docx.js <input.json> <output.docx>
if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.length >= 2) {
    const inputJsonPath = path.resolve(args[0]);
    const outputDocxPath = path.resolve(args[1]);
    const jsonData = JSON.parse(fs.readFileSync(inputJsonPath, 'utf8'));
    generateTestSpecDocx(jsonData, outputDocxPath)
      .then(p => console.log('Done:', p))
      .catch(err => { console.error('Error:', err); process.exit(1); });
  }
}
