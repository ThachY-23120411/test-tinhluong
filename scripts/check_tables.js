const sql = require('mssql');
const config = {
    user: 'sa',
    password: '123',
    server: '192.168.11.51',
    port: 2222,
    database: 'Vietinsoft_ForTest_Tai2',
    options: { encrypt: false, trustServerCertificate: true }
};
async function test() {
    try {
        await sql.connect(config);
        const ctCols = await sql.query("SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblLabourContract'");
        console.log('tblLabourContract columns:', ctCols.recordset.map(c => c.COLUMN_NAME).join(', '));
        
        const famCols = await sql.query("SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblFamilyInfo'");
        console.log('tblFamilyInfo columns:', famCols.recordset.map(c => c.COLUMN_NAME).join(', '));

        const sampleCt = await sql.query("SELECT TOP 1 * FROM tblLabourContract WHERE EmployeeID = '003'");
        console.log('Sample contract 003:', JSON.stringify(sampleCt.recordset[0], null, 2));

        const sampleFam = await sql.query("SELECT TOP 1 * FROM tblFamilyInfo WHERE EmployeeID = '003'");
        console.log('Sample family 003:', JSON.stringify(sampleFam.recordset[0], null, 2));

        process.exit(0);
    } catch(e) {
        console.error(e);
        process.exit(1);
    }
}
test();
