const fs = require('fs');
const path = require('path');

const files = [
  'fix-bug/screenshot-1/patch_responsive.sql',
  'fix-bug/screenshot-2/patch_responsive.sql',
  'fix-bug/screenshot-3/patch_hoso_canhan.sql',
  'fix-bug/screenshot-4/patch_tang_ca.sql',
  'fix-bug/screenshot-5/patch_tao_mat_khau.sql',
  'fix-bug/screenshot-6/patch_responsive_company_list.sql',
  'fix-bug/screenshot-8/patch_hop_dong_lao_dong.sql',
  'fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql',
  'fix-bug/screenshot-13/patch_fix_debt_loading.sql',
  'fix-bug/screenshot-14/patch_email_kpi_follow.sql',
  'fix-bug/screenshot-15/patch_fix_meeting_filter.sql',
  'fix-bug/screenshot-16/patch_theo_doi_dich_vu.sql',
  'fix-bug/screenshot-17/patch_email_gui_thu_cong.sql',
  'fix-bug/screenshot-18/patch_du_lieu_khach_hang.sql',
  'fix-bug/thanh_toan_cong_no/RESPONSIVE-DGV/patch_responsive_dgv.sql'
];

files.forEach(f => {
  if (fs.existsSync(f)) {
    const txt = fs.readFileSync(f, 'utf8');
    const procs = [...txt.matchAll(/(?:CREATE|ALTER)\s+PROCEDURE\s+\[?dbo\]?\.\[?([a-zA-Z0-9_]+)\]?/gi)].map(m => m[1]);
    const genExec = [...txt.matchAll(/sp_GenerateHTMLScript_new\s+'([^']+)'/gi)].map(m => m[1]);
    const tblSigned = txt.includes('tblCommonControlType_Signed');
    const tblCache = txt.includes('tblHtmlScriptCache');
    console.log(`=== ${path.basename(path.dirname(f))} / ${path.basename(f)} ===`);
    console.log('  Procedures:', [...new Set(procs)]);
    console.log('  GenerateHTMLScript:', [...new Set(genExec)]);
    console.log('  Modifies tblCommonControlType_Signed:', tblSigned);
    console.log('  Modifies tblHtmlScriptCache:', tblCache);
  }
});
