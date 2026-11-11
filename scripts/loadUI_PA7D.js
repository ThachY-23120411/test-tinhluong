
            if (typeof window.hpaControlEngine === "undefined") {
                console.error("[hpaControlText] window.hpaControlEngine chưa được load. Vui lòng load thủ tục sp_hpaControlEngineLoadUI trước.");
                return;
            }

            // Define getters in case outer code mutates the variables
            let _autoSaveFullNamePA7D7F5081185488CA62C1F211136902A = false;
            let _readOnlyFullNamePA7D7F5081185488CA62C1F211136902A = false;

            window.hpaControlEngine.initTextBoxManual({
                uid: "PA7D7F5081185488CA62C1F211136902A",
                columnName: "FullName",
                displayName: "%FullName%",
                tableId: "-99218308",
                columnIDName: "EmployeeID",
                columnIDName2: "",
                isRequired: 0,
                customValidate: function() { return typeof 0 === "function" ? 0.apply(this, arguments) : true; },
                saveErrorMessage: "%SaveErrorMessage%",
                gridColumnName: "0",
                keyUpdateGrid: "0",
                tabIndex: "0",
                getAutoSave: function() { return _autoSaveFullNamePA7D7F5081185488CA62C1F211136902A; },
                getReadOnly: function() { return _readOnlyFullNamePA7D7F5081185488CA62C1F211136902A; }
            });
        