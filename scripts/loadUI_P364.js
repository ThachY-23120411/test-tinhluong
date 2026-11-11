
            if (typeof window.hpaControlEngine === "undefined") {
                console.error("[hpaControlText] window.hpaControlEngine chưa được load. Vui lòng load thủ tục sp_hpaControlEngineLoadUI trước.");
                return;
            }

            // Define getters in case outer code mutates the variables
            let _autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = false;
            let _readOnlyEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = false;

            window.hpaControlEngine.initTextBoxManual({
                uid: "P3649C063B0674562BCCA3FB6B2F4DBF6",
                columnName: "Email",
                displayName: "%Email%",
                tableId: "-99218308",
                columnIDName: "EmployeeID",
                columnIDName2: "",
                isRequired: 0,
                customValidate: function() { return typeof 0 === "function" ? 0.apply(this, arguments) : true; },
                saveErrorMessage: "%SaveErrorMessage%",
                gridColumnName: "0",
                keyUpdateGrid: "0",
                tabIndex: "0",
                getAutoSave: function() { return _autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6; },
                getReadOnly: function() { return _readOnlyEmailP3649C063B0674562BCCA3FB6B2F4DBF6; }
            });
        