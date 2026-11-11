
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56DataSourceSP  = "sp_EmployeeListDataMultiSelectSelectBox";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56TableAddNew = "";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56ColumnAddNew  = "";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56CurrentSearch = "";
        let _autoSaveEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = false;
        let _readOnlyEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = false;
        let InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56      = null;

        let _isEditEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = window["_isEdit_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]     || false;
        let _isDeleteEmployeeIDP2D9DF38DBC46406C8EC1686058288F56   = window["_isDelete_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]   || false;
        let _hideIDEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = window["_hideID_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]     || false;
        let _hideSearchEmployeeIDP2D9DF38DBC46406C8EC1686058288F56 = window["_hideSearch_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"] || false;

        if (window.hpaControlEngine) {
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56 = window.hpaControlEngine.initSelectBoxManual({
                uid:            "P2D9DF38DBC46406C8EC1686058288F56",
                columnName:     "EmployeeID",
                displayName:    "%EmployeeID%",
                dataSourceSP:   "sp_EmployeeListDataMultiSelectSelectBox",
                tableAddNew:    "",
                tableAddNewD:   "",
                columnAddNew:   "",
                tableId:        "-99218308",
                columnIDName:   "EmployeeID",
                columnIDName2:  "",
                gridColumnName: "0",
                keyUpdateGrid:  "0",
                columnNameSync: "%ColumnNameSync%",
                isEdit:         _isEditEmployeeIDP2D9DF38DBC46406C8EC1686058288F56,
                isDelete:       _isDeleteEmployeeIDP2D9DF38DBC46406C8EC1686058288F56,
                getAutoSave:    function() { return _autoSaveEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getReadOnly:    function() { return _readOnlyEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getHideID:      function() { return _hideIDEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getHideSearch:  function() { return _hideSearchEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                actionRichTextEditor: function(e, instance) {
                    
                },
                isAdminOrManager: window.hpaIsAdminOrManager,
                loadDataSourceCommon: (typeof loadDataSourceCommon !== 'undefined' ? loadDataSourceCommon : undefined),
                saveFunction: (typeof saveFunction !== 'undefined' ? saveFunction : undefined),
                updateOrDeleteDataExample: (typeof updateOrDeleteDataExample !== 'undefined' ? updateOrDeleteDataExample : undefined)
            });
        }
        