
CREATE PROCEDURE [dbo].[sp_MakeupHours_html]

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @html nvarchar(max),
	@GroupButton nvarchar(max) = ''
	exec sp_getGroupButtonRequest @html = @GroupButton OUTPUT
	SET @html = N'
<!DOCTYPE html>
<html lang="vi">
<div class="w-100 m-0 content" style="position: relative" id="sp_MakeupHours">
	<style>
    /* === [TASK #7339] ĐỒNG BỘ WIDTH 768PX & TƯƠNG THÍCH THEME === */
    #sp_MakeupHours .container_sp_MakeupHours {
        max-width: 768px !important;
        margin-left: auto !important;
        margin-right: auto !important;
    }
    /* Đảm bảo toàn bộ card lịch sử có chiều cao auto, không bao giờ bị dãn màn hình */
    #sp_MakeupHours #historyCardBody .card,
    #sp_MakeupHours .history-card,
    #contentContainer_sp_MakeupHours #historyCardBody .card {
        min-height: auto !important;
        height: auto !important;
        margin-bottom: 12px !important;
        padding: 12px 16px !important;
        border-radius: 10px !important;
        background-color: var(--paradise-card-bg, var(--bs-card-bg, #ffffff)) !important;
        color: var(--paradise-text-color, var(--bs-body-color, #212529)) !important;
        border: 1px solid var(--paradise-border-color, rgba(0, 0, 0, 0.1)) !important;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

        textarea#ghiChuNguoiDuyet2 {
            color: gray;
        }

		#sp_MakeupHours .container_sp_MakeupHours {
			max-width: 768px;
			margin-left: auto;
			margin-right: auto;
		}

        #sp_MakeupHours .col-form-label {
            font-size: 0.9rem;
            color: gray;
			padding-top: 0px !important;
        }

		#sp_MakeupHours .col-sm-2 {
			width: 100% !important;
		}

		#sp_MakeupHours .col-sm-6 {
			width: 100% !important;
		}

 #sp_MakeupHours .card {
 overflow: auto;
        }
		#sp_MakeupHours .hr-employee-item {
			display: flex;
			align-items: center;
			padding: 12px;
			margin-bottom: 12px;
			background-color: var(--bs-secondary-bg);
			border-radius: 12px;
			box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
			transition: all 0.2s ease;
			justify-content: space-between;
		}

		#sp_MakeupHours .file-info {
			display: flex;
			gap: 12px;
		}

        #sp_MakeupHours .form-label {
            font-size: 0.9rem;
            color: gray;
        }

        #sp_MakeupHours select#loaiNghi {
            font-size: 0.9rem;
        }

        #sp_MakeupHours .from_day2 {
            width: 100%;
            margin-bottom: 0.3rem;
        }

        #sp_MakeupHours .to_day2 {
            width: 50%;
        }

        #sp_MakeupHours label.form-check-label {
            font-size: 0.9rem;
        }

		#sp_MakeupHours .date-text {
			font-size: 0.9rem;
			color: gray;
			font-weight: 400;
		}

        #sp_MakeupHours .form-check {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        #sp_MakeupHours .form-check-input {
            margin-right: 10px;
            /* Khoảng cách giữa nút radio và nhãn */
        }

        #sp_MakeupHours .form-check {
            display: inline-block;
            padding: 8px 8px 8px 38px;
            border-radius: 5px;
            border: 2px solid transparent;
            transition: border-color 0.3s, background-color 0.3s;
        }

        /* .form-check-input:checked+.form-check {
            border-color: #007bff;
            background-color: #e9f5ff;
        } */
        #sp_MakeupHours span#add-time {
    display: flex;
            justify-content: center;
            align-items: center;
            font-size: 1.6rem;
            border: 1px solid #dee2e6;
            height: 40px;
            width: 40px;
            margin-left: 10px;
            border-radius: 10px;
        }

        #sp_MakeupHours span.bi.bi-trash.remove-time {
            color: red;
            font-size: 1.5rem;
            margin-left: 10px;
            height: 40px;
            width: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }

        #sp_MakeupHours small#fileError2 {
            display: block;
            font-size: 0.9rem;
        }

        button#openFileButton {
            background-color: var(--vc-green-transparent005);
            border: 0.3px solid var(--vc-green-transparent02) !important;
            color: var(--bs-green) !important;
            border-radius: 1.25rem;
            font-size: 1.1rem;
            padding: 5px;
        }

        button#downloadFileButton {
            background-color: var(--vc-red-transparent005);
            border: 0.3px solid var(--vc-red-transparent02) !important;
            color: var(--vc-red) !important;
          border-radius: 1.25rem;
            font-size: 1.1rem;
            padding: 5px;
            margin-left: 5%;
        }

        #imageInPopup1 {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .img-container {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
            height: 100%;
            overflow: hidden;
            /* Ngăn hiện tượng tràn */
        }

        #nameFileInput {
            font-size: 0.9rem;
            overflow: scroll;
            white-space: nowrap;
            border: 0.5px solid gray;
            padding: 5px;
            border-radius: 3px;
        }
		#sp_MakeupHours .custom-tabs {
			display: flex;
			justify-content: center;
			border-bottom: 1.5px solid #e0e0e0;
			/*margin-bottom: 18px;*/
			width: 100%;
			margin-left: auto;
			margin-right: auto;
			height: 50px;
		  }

		#sp_MakeupHours .back-button {
			background: none;
            border: none;
            color: #00673b;
            font-size: 20px;
			margin-left: 12px;
            margin-right: 12px;
            padding: 5px;
            border-radius: 50%;
            transition: background-color 0.3s;
        }

		#sp_MakeupHours .custom-tab-btn {
			background: none;
			border: none;
			outline: none;
			font-size: 14px;
			color: #7b8794;
			font-weight: 400;
			position: relative;
			transition: color 0.2s;
			margin-bottom: -2px;
			flex: 1 1 0;
			text-align: center;
			width: 50%;
		  }
		#sp_MakeupHours  .custom-tab-btn.active {
			color: #0b6b3a;
			font-weight: bold;
		  }
		#sp_MakeupHours  .custom-tab-btn.active::after {
			content: "";
			display: block;
			height: 3px;
			width: 90%;
			background: #0b6b3a;
			border-radius: 2px;
			position: absolute;
			left: 5%;
			bottom: -2px;
		  }

		  #sp_MakeupHours .custom-tabs {
				position: relative;
				padding-left: 60px; /* Để chừa chỗ cho nút back */
			}

			#sp_MakeupHours .back-button {
				position: absolute;
				left: 12px;
				top: 50%;
				transform: translateY(-50%);
			}

		/* CSS cho phần hiển thị file đã chọn */
		#sp_MakeupHours .preview-container {
			display: flex;
			flex-wrap: wrap;
			gap: 10px;
			margin-top: 10px;
		}

		/* Style cho từng item file */
		#sp_MakeupHours .preview-item {
			display: flex;
			align-items: center;
			padding: 8px;
			background-color: #fff;
			border: 1px solid #dee2e6;
			border-radius: 6px;
			box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
			transition: all 0.3s ease;
		}

		#sp_MakeupHours .preview-item:hover {
			background-color: #f8f9fa;
			box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
		}

		#sp_MakeupHours .preview-item img {
			max-width: 40px;
			max-height: 40px;
			margin-right: 8px;
			border-radius: 4px;
		}

		#sp_MakeupHours .preview-item .file-icon {
			font-size: 20px;
			margin-right: 8px;
			color: #6c757d;
		}

		#sp_MakeupHours .preview-item .file-name {
			flex-grow: 1;
			font-size: 0.85rem;
			color: #333;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
			max-width: 150px;
		}

		/* Thiết kế lại nút xem và xóa */
		#sp_MakeupHours .preview-item {
			display: flex;
			gap: 10px;
		}

		#sp_MakeupHours .preview-item .preview-btn,
		#sp_MakeupHours .preview-item .remove-time {
			padding: 4px 10px;
			border: none;
			border-radius: 8px;
			font-size: 0.9rem;
			cursor: pointer;
			transition: all 0.3s ease;
		}

		#sp_MakeupHours .preview-item .preview-btn {
			display: flex;
			justify-content: center;
			align-items: center;
			background-color: #28a745;
			color: #fff;
			height: 30px;
			width: 50px;
		}

		#sp_MakeupHours .preview-item .preview-btn:hover {
			background-color: #218838;
		}

		#sp_MakeupHours .preview-item .remove-time {
			display: flex;
			justify-content: center;
			align-items: center;
			background-color: #dc3545;
			color: #fff;
			height: 30px;
			width: 50px;
		}

		#sp_MakeupHours .preview-item .remove-time:hover {
			background-color: #c82333;
		}

/* Container chính */
#sp_MakeupHours #historyCardBody {
    min-height: 400px;
}

/* Card chấm công */
#sp_MakeupHours .history-card {
    display: flex;
    justify-content: space-between;
    background: white;
    padding: 16px 20px;
    transition: all 0.2s ease;
	border-top: none !important;
	border-left: none !important;
	border-right: none !important;
	border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

#sp_MakeupHours .history-card:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    background: #fafafa;
}

/* Avatar và icon */
#sp_MakeupHours .history-card .avatar-img {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 16px;
    border: 2px solid #e9ecef;
    flex-shrink: 0;
}

#sp_MakeupHours .history-card .fas.fa-user-circle {
    font-size: 60px;
    color: #6c757d;
    margin-right: 16px;
    opacity: 0.8;
    flex-shrink: 0;
}

/* Container thông tin */
/* Header thông tin nhân viên - nằm ngang */
#sp_MakeupHours .employee-header {
    display: flex;
    align-items: baseline;
    margin-bottom: 8px;
    flex-wrap: wrap;
}

#sp_MakeupHours .employee-id {
    font-size: 14px;
    font-weight: 500;
    color: #28a745;
    margin: 0;
}

/* Chi tiết chấm công */
#sp_MakeupHours .attendance-details {
	display: flex;
    font-size: 14px;
    color: #495057;
    line-height: 1.4;
}

#sp_MakeupHours .employee-info {
	width: 60%;
}

#sp_MakeupHours .status-container {
	margin-top: auto;
	margin-left: auto;
}

#sp_MakeupHours .label {
    font-weight: 700;
	font-size: 12px;
    color: #2c3e50;
}

/* Các nút trạng thái */
#sp_MakeupHours .status-pending {
    background: #fff;
    color: #007bff;
    border: 1px solid #007bff;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

#sp_MakeupHours .status-approved {
    background: #fff;
    color: #28a745;
    border: 1px solid #28a745;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
}

#sp_MakeupHours .status-rejected {
    background: #fff;
    color: #dc3545;
    border: 1px solid #dc3545;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
}

#sp_MakeupHours .status-cancelled {
    background: #fff;
    color: #6c757d;
    border: 1px solid #6c757d;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
}

#sp_MakeupHours .status-unknown {
    background: #fff;
    color: #6c757d;
    border: 1px solid #6c757d;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
}

/* Responsive cho mobile */
@media (max-width: 768px) {
    #sp_MakeupHours .history-card {
        flex-direction: column;
        align-items: flex-start;
        padding: 8px 0px;
    }

    #sp_MakeupHours .card_left {
        margin-bottom: 12px;
        width: 100%;
    }

 #sp_MakeupHours .attendance-details {
        font-size: 13px;
    }
}

@media (max-width: 480px) {
    #sp_MakeupHours .card_left {
        align-items: flex-start;
    }

    #sp_MakeupHours .history-card .avatar-img,
    #sp_MakeupHours .history-card .fas.fa-user-circle {
        margin-right: 0;
        margin-bottom: 8px;
    }
}

/* Animation cho loading */
#sp_MakeupHours .loading-animation {
    display: flex;
justify-content: center;
    align-items: center;
    height: 200px;
}

#sp_MakeupHours .loading-spinner {
    width: 30px;
 height: 30px;
border: 3px solid #f3f3f3;
    border-top: 3px solid #007bff;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* CSS cho phần thông tin nhân viên */
#sp_MakeupHours .employee-detail-info {
    display: none; /* Ẩn mặc định */
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

#sp_MakeupHours .employee-detail-info.show {
    display: flex;
    align-items: center;
}

#sp_MakeupHours .employee-detail-info .employee-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 16px;
    border: 2px solid #e9ecef;
    flex-shrink: 0;
}

#sp_MakeupHours .employee-detail-info .employee-avatar.default-avatar {
    font-size: 60px;
    color: #6c757d;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #e9ecef;
}

#sp_MakeupHours .employee-detail-info .employee-details h5 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #2c3e50;
}

#sp_MakeupHours .employee-detail-info .employee-details p {
    margin: 4px 0 0 0;
    font-size: 14px;
    color: #6c757d;
}

// Thêm CSS cho các nút phê duyệt
#sp_MakeupHours #approvalButtons {
			display: none;
			justify-content: center;
			gap: 15px;
			margin-top: 20px;
			padding-top: 15px;
			border-top: 1px solid #e9ecef;
		}

		#sp_MakeupHours #approvalButtons.show {
			display: flex;
		}

		#sp_MakeupHours .btn-approve {
			background-color: var(--paradise-color-success);
			border: 1px solid var(--paradise-color-success);
			color: white;
			padding: 12px 24px;
			border-radius: 20px;
			font-size: 14px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.3s ease;
			min-width: 120px;
		}

		#sp_MakeupHours .btn-approve:hover {
			background-color: #218838;
			border-color: #1e7e34;
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(40, 167, 69, 0.3);
		}

		#sp_MakeupHours .btn-reject {
			background-color: var(--paradise-color-danger);
			border: 1px solid var(--paradise-color-danger);
			color: white;
			padding: 12px 24px;
			border-radius: 20px;
			font-size: 14px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.3s ease;
			min-width: 120px;
		}
		#sp_MakeupHours .btn-reject:hover {
			background-color: #c82333;
			border-color: #bd2130;
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(220, 53, 69, 0.3);
		}
		#sp_MakeupHours .btn-cancel {
			background-color: var(--paradise-color-warning);
			border: 1px solid var(--paradise-color-warning);
			color: white;
			padding: 12px 24px;
			border-radius: 20px;
			font-size: 14px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.3s ease;
			min-width: 120px;
		}
		#sp_MakeupHours .btn-cancel:hover {
			background-color: #e0a800;
			border-color: #d39e00;
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(255, 193, 7, 0.3);
		}
    </style>
</head>
<body>
	<div class="card container_sp_MakeupHours" style="border: 0px">
		<div class="custom-tabs">
			<button class="back-button" onclick="backMenuFromStack()" style="position: absolute; left: 0;">
				<i class="bi bi-arrow-left"></i>
			</button>
			<button class="custom-tab-btn active" onclick="showTab(0)">%MnuHRS033%</button>
			<button class="custom-tab-btn" onclick="showTab(1)">%HistoryRequest%</button>
		</div>
		<div class="Information" id="tab-0" style="display:block;">
			<div class="container">
				<div class="row" id="fromtoday1">
					<div id="employeeDetailInfo" class="col-12 mb-2 mt-2">
					</div>
					<div class="from_day2 required">
						<label for="pickedDay" class="col-sm-2 col-form-label">
							<i class="bi bi-calendar3 me-1"></i>
							<label class="date-text">%Date%</label>
							(*)
						</label>
						<div class="col-sm-4">
							<input type="date" class="form-control" id="AttDate" oninput="validateField(''AttDate'')" />
							<div class="validate_error_date0 active" style="color: red"></div>
						</div>
					</div>
					<div class="mb-2 time-entry d-flex required">
						<div class="to_day2" style="padding-right: calc(var(--bs-gutter-x) * 0.5)">
							<label for="pickedTime" class="col-sm-2 col-form-label">
								<i class="bi bi-door-open-fill me-1"></i>
								<label class="checkinout-text">%CheckinOut%</label>
								(*)
							</label>
							<div class="col-sm-4">
								<div class="d-flex">
									<select style="width: 100%" class="form-control select-inout" id="select_inout">
										<option class="checkin-text" value="1" id="In">%Status_In%</option>
										<option class="checkout-text" value="2" id="Out">%Status_Out%</option>
									</select>
								</div>
							</div>
						</div>
						<div class="to_day2 required" style="padding-left: calc(var(--bs-gutter-x) * 0.5)">
							<label for="pickedTime" class="col-sm-2 col-form-label">
								<i class="bi bi-calendar3 me-1"></i>
								<label class="time-text">%Time%</label>
								(*)
							</label>
							<div class="col-sm-4">
								<div class="d-flex">
									<input style="width: 85%" type="time" class="form-control extra-time" id="TimeInOut" oninput="validateField(''TimeInOut'')" />
									<span class="add-time bi bi-plus" id="add-time"></span>
								</div>
								<div class="validate_error_date1 active" style="color: red"></div>
							</div>
						</div>
						<div class="validate_error_date active required" style="color: red">
							<span class="validate-date-text"></span>
						</div>
					</div>
					<div id="extra-time-fields" class="col-sm-6"></div>
				</div>
				<div class="mb-3">
					<div style="display: flex; align-items: center;">
						<input type="checkbox" id="isSoftwareError"
							   style="width: 17px; height: 17px; cursor: pointer; margin: 0; flex-shrink: 0;">
						<label for="isSoftwareError" class="date-text"
							   style="margin-left: 10px; margin-bottom: 0; cursor: pointer; user-select: none; line-height: 1;">
							%AttWithErr%
						</label>
					</div>
				</div>
				<div class="mb-2 required" id="divLyDo1">
					<label for="lyDo2" class="form-label">
						<i class="bi bi-emoji-smile me-1"></i>
						<label class="reason-text">%Reason%</label>
						(*)
					</label>
					<textarea class="form-control" id="Note" rows="3" oninput="validateField(''Note'')"></textarea>
				</div>
				<div class="mb-2" id="attachfile2">
					<label for="fileInput2" class="form-label">
						<i class="fa-solid fa-upload"></i>
						<label class="attach-text">%ChoseFile%</label>
					</label>
					<div class="fileTrans" id="ShowFileMakeupHours">
						<input type="file" id="NtBeta-FileForMakeupHours" multiple style="display: none;" />
							<div id="customchosefileMakeupHours" class="file-select-button"></div>
							<div class="mt-3" id="NtBeta-FilePreviewContainer"></div>
					</div>
					<input type="text" class="form-control" id="nameFileInput2" rows="3" style="display: none" />
					<small id="fileError2" class="text-danger mt-2"></small>
				</div>
				<div class="">
						<i class="fas fa-user-check"></i>
						<label class="section-title form-label">%Approval_Process%</label>
						<div class="timeline parent-timeline" id="container_approval_process">
						</div>	
                </div>
				<div class="mb-2 row mt-0">
					<div class="trangThai2">
						<label for="trangThai2" class="form-label">
							<i class="bi bi-airplane-fill me-1"></i>
							<label class="status-text">%Status%</label>
						</label>
						<input type="text" class="form-control" id="trangThai2" readonly />
					</div>
				</div>
				'+@GroupButton+N'
			</div>
			<div id="filePreviewModal" class="modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); z-index: 1000;">
				<div class="modal-content" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background-color: white; padding: 20px; border-radius: 10px; width: 80%; max-height: 80%; overflow-y: auto;">
					<span class="modal-close">×</span>
					<div class="modal-body" id="modalBody"></div>
				</div>
			</div>
			  <div id="container-penddingrequestAtt" class="container d-none">
				   <label class="form-label fw-bold border-bottom pb-1 d-block text-warning mt-4" style="font-size: 20px;">Đơn chờ duyệt</label>
				   <div id="AttendRequestPendding">
				   </div>
			  </div>
		</div>
		<div class="container px-2" id="tab-1" style="display: none;">
			 <div id="historyCardBody" class="pt-2 request-CardList "></div>
		</div>
		<div class="modal fade shadow" id="modalApproveAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="ghiChuNguoiDuyet2" rows="3" style="height: 127px"></textarea>
		                </div>
					</div>
					<div class="modal-footer">
		                <button type="button" class="btn" onClick="HandleApproveAttendanceRequest()" id="btnApproveModalRemake">%Approved%</button>
                        <button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
		<div class="modal fade shadow" id="modalRejectAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="remake " rows="3" style="height: 127px"></textarea>
		                </div>
					</div>
					<div class="modal-footer">
		                <button type="button" class="btn" onClick="HandleRejectAttendanceRequest()" id="btnRejectModalRemake">%Approved%</button>
                        <button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
		<div class="modal fade shadow" id="modalCancelAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="NoteCancel" rows="3" style="height: 127px"></textarea>
		                </div>
					</div>
					<div class="modal-footer">
		                <button type="button" class="btn btn-danger" onClick="HandleCancelAttendanceRequest()" id="btnCancelModalRemake">%confirm%</button>
                        <button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
<script>
var fileList = [];
var modal = $("#filePreviewModal");
var modalBody = $("#modalBody");
var closeModal = $(".modal-close");
var ntBetaJsonFilesSelected = []
var IsRegisterExp = true;
var Current_IdentityID = "";

// Devexpress
	function DevexpressDesign() {
		$(''#btnSelectFile'').dxButton({
			icon: "upload",
			stylingMode: ''contained'',
			text: ''%ChoseFile%'',
			type: ''normal'',
			width: 150,
		})	
		$(''#customchosefileMakeupHours'').dxButton({
			icon: "upload",
			stylingMode: ''contained'',
			text: ''%ChoseFile%'',
			type: ''normal'',
			width: 150,
			onClick: async function (){
				if (ParadiseOption.AppInfoVersionString.length > 0 && getMobileOperatingSystem() == "Android") {							
					var result = await apimobileAjaxAsync({}, {
						"MethodName": "MobileFilePickerMultipleAsync",
						"prs": [],
					});
				if (result == "Object reference not set to an instance of an object") {	
					HideLoadingByClassOrID();
					return
				}
				showLoadingByClassOrID("#sp_MakeupHours");
				var promises = result.map(async (file, i) => {
					const optimized = await optimizeImageBase64IfNeeded({
						fileName: file.fileName,
						data: file.data
					});
					optimized.uid = Date.now() + ''_'' + i;
					return optimized;
				});
				var arrFileNew = await Promise.all(promises);
				ntBetaJsonFilesSelected.push(...arrFileNew)
				ntBetaAddFileUi(ntBetaJsonFilesSelected);
				HideLoadingByClassOrID();
				} else {
							$("#NtBeta-FileForMakeupHours").trigger("click");
						}
					},
				});
			}

//Hàm xóa phần header mặc định của hệ thống
	function start () {
		$("#header_sp_MakeupHours").addClass("d-none");
		$("#contentContainer_sp_MakeupHours").css("height", "calc(100vh - 60px)");
	}

//Hàm chuyển tab
	function showTab(idx) {
		var buttons = document.querySelectorAll(''.custom-tab-btn'');
		var tabs = [
			document.getElementById(''tab-0''),
			document.getElementById(''tab-1'')
		];
		clearAllValidationErrors();
		buttons.forEach((btn, i) => {
			if (i === idx) {
				btn.classList.add(''active'');
				tabs[i].style.display = ''block'';
				if (i === 1) { // Tab History
					if (IsRegisterExp) {
						LoadAttendanceHistory(); // Gọi hàm tải lịch sử chung
					} else {
						LoadHistoryByIdentityID(); // Gọi hàm tải lịch sử theo IdentityID
					}
				}
			} else {
				btn.classList.remove(''active'');
				tabs[i].style.display = ''none'';
			}
		});
	}

//Hàm thêm và xóa mục vào ra
	document.getElementById(''add-time'').addEventListener(''click'', function (e) {
		if ($(this).prop(''disabled'')) {
			e.preventDefault();
			return;
		}
		var extraTimeFields = document.getElementById(''extra-time-fields'');
		var currentTimeFields = extraTimeFields.querySelectorAll(''.extra-time'');
		if (currentTimeFields.length < 7) {
			var newTimeField = document.createElement(''div'');
			newTimeField.className = ''mb-2 time-entry'';
			var index = currentTimeFields.length;
			newTimeField.innerHTML = `
			<div class="row" data-index="${index}">
				<div class="to_day2">
					<label for="select_inout_${index}" class="col-sm-2 col-form-label">
						<span class="bi bi-door-open-fill me-1"></span>${`%CheckinOut%`} (*)</label>
					<div class="col-sm-4">
						<div class="d-flex">
							<select style="width: 100%;" class="form-control select-inout" id="select_inout_${index}">
								<option value="1" id="In">${`%Status_In%`}</option>
								<option value="2" id="Out">${`%Status_Out%`}</option>
							</select>
						</div>
					</div>
				</div>
				<div class="to_day2">
					<label for="extraTime_${index}" class="col-sm-2 col-form-label"><span class="bi bi-calendar3 me-1"></span>${`%Time%`} (*)</label>
					<div class="col-sm-4 d-flex">
						<input type="time" class="form-control extra-time" id="extraTime_${index}" style="width:85%;">
						<span class="bi bi-trash remove-time"></span>
					</div>
				</div>
			</div>
		`;
			extraTimeFields.appendChild(newTimeField);
			newTimeField.querySelector(''.remove-time'').addEventListener(''click'', function () {
				newTimeField.remove();
			});
			// Chỉ đặt giá trị mặc định cho input mới
			$(`#extraTime_${index}`).val(''08:00'');
		} else {
			MainToast.ShowToast(`%Max8Time%`, ''error'');
		}
	});

// Hàm kiểm tra các trường bắt buộc
	function validateRequiredFields_MakeupHours() {
		var isValid = true;

		// Chỉ validate khi form đã được initialize đầy đủ
		if (!isFormInitialized()) {
			return true; // Không validate nếu form chưa ready
		}

		var requiredFields = document.querySelectorAll(''.required input, .required select, .required textarea'');

		// Reset tất cả trạng thái lỗi trước
		requiredFields.forEach(field => {
			field.classList.remove(''required-error'');
		});

		requiredFields.forEach(field => {
			if (field.tagName === ''SELECT'') {
				if (field.value === '''' || field.value === ''0'') {
					field.classList.add(''required-error'');
					isValid = false;
				}
			}
			else if (field.type === ''date'') {
				if (!field.value) {
					field.classList.add(''required-error'');
					isValid = false;
				}
			}
			else {
				if (!field.value.trim()) {
					field.classList.add(''required-error'');
					isValid = false;
				}
			}
		});
		if (!isValid) {
			showNotification("%lblerror%", "%RequiredFieldsMissing%", "error");
			var firstError = document.querySelector(''.required-error'');
			if (firstError) {
				firstError.scrollIntoView({ behavior: ''smooth'', block: ''center'' });
			}
		}
		return isValid;
	}

	function isFormInitialized() {
		// Kiểm tra các element chính đã tồn tại và sẵn sàng
		return document.getElementById("AttDate") &&
			   document.getElementById("select_inout") &&
			   document.getElementById("TimeInOut") &&
			   document.getElementById("Note");
	}

// Reset file đính kèm
    ntBetaJsonFilesSelected = [];
    ntBetaAddFileUi(ntBetaJsonFilesSelected);
    $("#NtBeta-FileForMakeupHours").val("");
    $("#customchosefileMakeupHours").show();

//Nhấn nút lưu
	function SubmitRequestMakeupHours() {
		if (!validateRequiredFields_MakeupHours()) return;
		var employeeID = UserID;
		var attDate = document.getElementById("AttDate").value;
		var reason = document.getElementById("Note").value;
		var approveStatus = 0;
		var checkInOutType = document.getElementById("select_inout").value;
		var timeInOut = document.getElementById("TimeInOut").value;
		var extraTimeFields = document.querySelectorAll("#extra-time-fields .row");
		var additionalTimes = [];
		var isError = document.getElementById(''isSoftwareError'').checked ? 1 : 0;
		extraTimeFields.forEach(row => {
			var inout = row.querySelector(".select-inout").value;
			var time = row.querySelector("input[type=''time'']").value;
			additionalTimes.push({ inout, time });
		});
		var allTimeData = [
			{ inout: checkInOutType, time: timeInOut },
			...additionalTimes
		];
		var jsonTime = JSON.stringify(allTimeData);
		var jsonfile = "";
		if(ntBetaJsonFilesSelected.length > 0) jsonfile = JSON.stringify(ntBetaJsonFilesSelected)
		showConfirmPopup({
			title: "%ConfirmRegister%",
			message: "%ConfirmRegisterDeatail%?",
			icon: "bi bi-question-circle",
			onYes: function() {	
				AjaxHPAParadise({
					data: {
						name: "sp_InsertInOut",
						param: [
							"LoginID", employeeID,
							"LanguageID", LanguageID,
							"AttDate", attDate,
							"Reason", reason,
							"Approve_Status", approveStatus,
							"JsonTime", jsonTime,
							"JsonFile", jsonfile,
							"Error", isError]
					},
					success: function (result) {
						try {
							var json = JSON.parse(result);

							// Lấy dòng đầu tiên của kết quả trả về từ SQL (nếu có)
							if (json && json.data && json.data.length > 0 && json.data[0].length > 0) {
								var row = json.data[0][0];

								// Nếu SQL trả về status = 0 (Lỗi do mình quy định)
								if (row.status === 0) {
									showNotification("Thất bại", row.message, "error");
									return; // Dừng, không chạy clearForm nữa
								}
							}

							// Nếu có lỗi hệ thống hoặc framework chèn vào biến error
							if (json && json.error) {
								showNotification("Lỗi", json.error, "error");
								return;
							}
						} catch(e) {
							console.log("Không parse được JSON trả về:", e);
						}
						clearFormAfterSubmit();	
						showNotification("%lblSuc%", "%RegistedSuccsess%.", "success");
					}
				});
			}
		});
	}

//Kích hoạt nút lưu khi nhấn
	$("#sp_MakeupHours .btnRegister").on("click", function() {SubmitRequestMakeupHours()});

//Hàm reset lại các ô
	function clearFormAfterSubmit() {
		clearAllValidationErrors();
		document.getElementById("AttDate").value = ""; // Reset ngày
		document.getElementById("select_inout").value = "1"; // Reset loại vào/ra		
		document.getElementById("TimeInOut").value = ""; // Reset giờ vào/ra
		// Xóa tất cả dòng giờ bổ sung
		var extraFields = document.getElementById("extra-time-fields");
		extraFields.innerHTML = "";		
		document.getElementById("Note").value = ""; // Reset lý do
		// Reset trạng thái hiển thị
		document.getElementById("trangThai2").value = "";
		document.getElementById("ghiChuNguoiDuyet2").value = "";
		document.getElementById("isSoftwareError").checked = false;
		// Reset file đính kèm
		ntBetaJsonFilesSelected = [];
		$("#NtBeta-FilePreviewContainer").empty(); // Xóa hoàn toàn container hiển thị file
		$("#NtBeta-FileForMakeupHours").val(""); // Reset input file
		$("#customchosefileMakeupHours").dxButton("instance").option({
			text: "%ChoseFile%",
			disabled: false
		}); // Đặt lại trạng thái nút chọn file
		$("#fileError2").text(""); // Xóa thông báo lỗi file nếu có
		// Xóa lỗi hiển thị nếu còn
		document.querySelectorAll(".required-error").forEach(el => {
			el.classList.remove("required-error");
		});
	}

// Thêm sự kiện khi người dùng nhập liệu để xóa lỗi
	document.querySelectorAll(''.required input, .required select, .required textarea'').forEach(field => {
		field.addEventListener(''input'', function() {
			if (field.value && (field.tagName !== ''SELECT'' || field.value !== ''0'')) {
				field.classList.remove(''required-error'');
			}
		});
		field.addEventListener(''change'', function() {
			if (field.value && (field.tagName !== ''SELECT'' || field.value !== ''0'')) {
				field.classList.remove(''required-error'');
			}
		});
	});

// Hàm tải dữ liệu tab lịch sử
	function LoadAttendanceHistory() {
		AjaxHPAParadise({
			data: {
				name: "sp_GetAttendanceHistory",
				param: ["LanguageID", LanguageID,
						"LoginID", UserID
				]
			},
			success: function (result) {
				var data = JSON.parse(result).data;
				NtBetaArrRequestApprover = data[0]
				renderAttendanceHistory(NtBetaArrRequestApprover);
			}
		})
	}

	function LoadHistoryByIdentityID() {
		AjaxHPAParadise({
			data: {
				name: "sp_GetAttendanceHistoryWithIdentityID",
				param: ["LanguageID", LanguageID,
						"IdentityID", Current_IdentityID
				]
			},
			success: function (result) {
				var data = JSON.parse(result).data;
				NtBetaArrRequestApprover = data[0]
				renderAttendanceHistory(NtBetaArrRequestApprover);
			}
		})
	}

// Hàm tải render dữ liệu tab lịch sử
	function renderAttendanceHistory(list) {
		var $historyCardBody = $("#historyCardBody");
		$historyCardBody.empty();
		if (!list || list.length === 0) {
			$historyCardBody.append("<div>Không có lịch sử chấm công nào.</div>");
			return;
		}
		list.forEach(item => {
			var shiftName = item.ShiftName || "%NoInformation%";
			var card = $("<div class=''card history-card'' style=''min-height: auto !important; height: auto !important; margin-bottom: 12px !important;''></div>")
				.attr("data-identity-id", item.IdentityID)
				.html(`
					<div class="employee-info">
						<div class="request-subtitle mt-2">
							<b>%Date%:</b> ${formatDate(item.AttDate)}
						</div>
						<div class="request-subtitle">
							<b>%ShiftName%:</b> ${shiftName}
						</div>
						<div class="request-subtitle">
							<b>%Note%:</b> ${item.Remark}
						</div>
						<div class="request-subtitle">
							<b>%Time%:</b> ${item.ViewTime}
						</div>
					</div>
					${viewStatus(item.Approve_Status, item.ApproveStatusDescription)}	
				`);
			card.click(async function () {
				var identityID = $(this).attr("data-identity-id");
				showTab(0); // Chuyển về tab đầu tiên			
				getTimelineqlbeta(identityID, 5, "container_approval_process", "employeeDetailInfo"); // Hiển thị timeline người duyệt
				$("#sp_MakeupHours .btnRegister").addClass("d-none"); // Ẩn nút đăng kí
				fillFormWithHistoryData(item); // Fill dữ liệu vào form
				setFormReadOnly(true); // Set form readonly sau khi load xong
				Current_IdentityID = identityID;
				await InitdanceRequestPendding()
				// Load thông tin chi tiết và xử lý file
				LoadAttendanceInformation(identityID, function() {
					checkApprovalPermission(identityID);
					getTimelineqlbeta(identityID, 5, "container_approval_process", "employeeDetailInfo");
					fillFormWithHistoryData(item);
					checkCancelPermission(identityID)
				});
			});
			$historyCardBody.append(card);
		});
	}

// Hàm tải dữ liệu tab thông tin
	function LoadAttendanceInformation(identityID) {
		AjaxHPAParadise({
			data: {
				name: "sp_FillAttendanceInformation",
				param: [
					"LanguageID", LanguageID,
					"LoginID", UserID,
					"IdentityID", identityID
				]
			},
			success: function (result) {
				var data = JSON.parse(result).data;
				if (data && data.length > 0) {
					AttendanceInformation = data[0]; // Data set đầu tiên - thông tin attendance
					var FileURLs = data[1] || []; // Data set thứ hai - danh sách file URLs
					var inforequest = data[2] ? data[2] : []
					fillFormWithAttendanceInformation(AttendanceInformation); // Fill dữ liệu vào form
					handleFileDisplayFromDetail(AttendanceInformation, FileURLs); // Xử lý hiển thị file sử dụng cả hai nguồn dữ liệu
					getTimelineqlbeta(identityID, 5, "container_approval_process", "employeeDetailInfo"); // Hiển thị timeline người duyệt
					if(inforequest.length > 0)
					{
						fillFormWithHistoryData(inforequest[0])
					}
				}
				checkApprovalPermission(identityID);
				checkCancelPermission(identityID)
			},
			error: function(error) {
				console.error("Lỗi khi tải thông tin:", error);
				showNotification("%lblerror%", "%LoadDetailFailed%", "error");
			}
		});
	}

// Hàm định dạng ngày thành dd/mm/yyyy
	function formatDate(dateString) {
		if (!dateString) return "N/A";
		try {
			var date = new Date(dateString);
			if (isNaN(date.getTime())) return dateString; // Trả về chuỗi gốc nếu không parse được
			var day = date.getDate().toString().padStart(2, ''0'');
			var month = (date.getMonth() + 1).toString().padStart(2, ''0'');
			var year = date.getFullYear();
			return `${day}/${month}/${year}`;
		} catch (error) {
			return dateString; // Trả về chuỗi gốc nếu có lỗi
		}
	}

// Hàm định dạng ngày thành yyyy/mm/dd
	function formatDateForInput(dateString) {
		if (!dateString) return "";
		try {
			var date = new Date(dateString);
			if (isNaN(date.getTime())) return "";
			var year = date.getFullYear();
			var month = (date.getMonth() + 1).toString().padStart(2, ''0'');
			var day = date.getDate().toString().padStart(2, ''0'');
			return `${year}-${month}-${day}`;
		} catch (error) {
			return "";
		}
	}

//Hàm fill dữ liệu lên tab đầu
	function fillFormWithHistoryData(item) {
		clearAllValidationErrors();
		if (item.AttDate) {
			var inputDateFormat = formatDateForInput(item.AttDate);
			$("#AttDate").val(inputDateFormat);
		}
		$("#Note").val(item.Remark || ""); // Fill lý do
		$("#isSoftwareError").prop("checked", item.IsSoftwareError == 1);
		getTimelineqlbeta(item.IdentityID,5,"container_approval_process", "employeeDetailInfo")
		$("#trangThai2").val(item.ApproveStatusDescription || "123"); // Fill trạng thái
	}

// Hàm fill dữ liệu lên danh sách duyệt
	async function intitLoadRequest() {
		if(sp_MakeupHours_param.IdentityID){
			LoadAttendanceInformation(sp_MakeupHours_param.IdentityID)
			checkApprovalPermission(sp_MakeupHours_param.IdentityID);		
			setFormReadOnly(true);
			$("#sp_MakeupHours .btnRegister").addClass("d-none");
			Current_IdentityID = sp_MakeupHours_param.IdentityID;
			IsRegisterExp = false;
			await InitdanceRequestPendding()
		} else {
			Current_IdentityID = "";
			IsRegisterExp = true;
		}
	}

// Hàm xử lý hiển thị file riêng biệt
	function handleFileDisplay(item) {
		ntBetaJsonFilesSelected = []; // Reset file trước khi load
		// Kiểm tra và parse file từ JsonFile trong item (từ history data)
		if (item.JsonFile && item.JsonFile.trim() !== '''') {
			try {
				var parsedFiles = JSON.parse(item.JsonFile);
				if (Array.isArray(parsedFiles) && parsedFiles.length > 0) {
					ntBetaJsonFilesSelected = parsedFiles;
				}
			} catch (e) {
				console.error("Lỗi parse JsonFile:", e);
			}
		}
		// Nếu không có JsonFile, thử kiểm tra UrlFile từ item
		if (ntBetaJsonFilesSelected.length === 0 && item.UrlFile && item.UrlFile.trim() !== '''') {
			var fileName = item.UrlFile.split("\\").pop() || item.UrlFile.split("/").pop() || "unknown_file";
			ntBetaJsonFilesSelected = [{
				fileName: fileName,
				UrlFile: item.UrlFile,
				data: null // Không có data base64
			}];
		}
		ntBetaAddFileUi(ntBetaJsonFilesSelected, 1); // Hiển thị file với sender = 1 để ẩn nút xóa
	}

//Hiển thị danh sách file đính kèm từ dữ liệu chi tiết chấm công.
	function handleFileDisplayFromDetail(AttendanceInformation, FileURLs) {
		ntBetaJsonFilesSelected = []; // Reset file trước khi load

		// Ưu tiên sử dụng JsonFile từ AttendanceInformation nếu có
		if (AttendanceInformation && AttendanceInformation.JsonFile && AttendanceInformation.JsonFile.trim() !== '''') {
			try {
				var parsedFiles = JSON.parse(AttendanceInformation.JsonFile);
				if (Array.isArray(parsedFiles) && parsedFiles.length > 0) {
					// Clean fileName cho từng file trong JsonFile
					ntBetaJsonFilesSelected = parsedFiles.map(file => ({
						...file,
						fileName: sanitizeFileName(file.fileName || file.UrlFile)
					}));
				}
			} catch (e) {
				console.error("Lỗi parse JsonFile:", e);
			}
		}

		// Nếu không có JsonFile, sử dụng FileURLs từ stored procedure
		if (ntBetaJsonFilesSelected.length === 0 && FileURLs && Array.isArray(FileURLs) && FileURLs.length > 0) {
			ntBetaJsonFilesSelected = FileURLs.map(file => ({
				...file,
				fileName: sanitizeFileName(file.fileName || file.UrlFile)
			}));
		}

		// Nếu vẫn không có file, thử kiểm tra UrlFile trực tiếp
		if (ntBetaJsonFilesSelected.length === 0 && AttendanceInformation?.UrlFile?.trim()) {
			var cleanFileName = sanitizeFileName(AttendanceInformation.UrlFile);
			ntBetaJsonFilesSelected = [{
				fileName: cleanFileName,
				UrlFile: AttendanceInformation.UrlFile,
				data: AttendanceInformation.UrlFile
			}];
		}

		ntBetaAddFileUi(ntBetaJsonFilesSelected, 1);
	}

	function sanitizeFileName(fileName) {
		if (!fileName || typeof fileName !== ''string'') {
        return "unknown_file";
    }

    // Decode nếu fileName bị encode
    try {
        if (fileName.includes(''%'')) {
            fileName = decodeURIComponent(fileName);
        }
    } catch (e) {
        console.warn("Không thể decode fileName:", fileName);
    }

    // Loại bỏ các tham số query nếu có (phải làm trước khi clean ký tự khác)
    if (fileName.includes(''?'')) {
        fileName = fileName.split(''?'')[0];
    }
    if (fileName.includes(''&'')) {
        fileName = fileName.split(''&'')[0];
    }

    // Loại bỏ khoảng trắng thừa
    fileName = fileName.trim();

    // Loại bỏ các ký tự đặc biệt từ array/object notation và các ký tự không hợp lệ
    fileName = fileName.replace(/[\[\]<>:"/\\|?*"''{}()]/g, '''');

    // Loại bỏ các ký tự control characters và ký tự không in được
    fileName = fileName.replace(/[\x00-\x1f\x7f-\x9f]/g, '''');

    // Loại bỏ các ký tự đặc biệt ở đầu và cuối (bao gồm dấu chấm, gạch ngang, underscore)
    fileName = fileName.replace(/^[._\-]+|[._\-]+$/g, '''');

    // Xử lý trường hợp fileName rỗng sau khi clean
    if (!fileName || fileName.length === 0) {
        return "unknown_file";
    }

    // Đảm bảo có extension nếu không có
    if (!fileName.includes(''.'') && fileName !== "unknown_file") {
        fileName += ".file";
    }

    // Giới hạn độ dài tên file
    if (fileName.length > 100) {
        var lastDotIndex = fileName.lastIndexOf(''.'');
        if (lastDotIndex > 0) {
            var extension = fileName.substring(lastDotIndex);
            var nameWithoutExt = fileName.substring(0, lastDotIndex);
            fileName = nameWithoutExt.substring(0, 90 - extension.length) + extension;
        } else {
            fileName = fileName.substring(0, 90);
        }
    }

    return fileName || "unknown_file";
}

//Hàm fill dữ liệu thời gian cho tab đầu
	function fillFormWithAttendanceInformation(AttendanceInformation) {
		if (!AttendanceInformation) return;
		clearAllValidationErrors();
		var extraFields = document.getElementById("extra-time-fields");
		extraFields.innerHTML = "";
		var timeData = AttendanceInformation;
		if (AttendanceInformation.JsonTime) {
			try {
				if (typeof AttendanceInformation.JsonTime === ''string'') {
					timeData = JSON.parse(AttendanceInformation.JsonTime);
				} else {
					timeData = AttendanceInformation.JsonTime;
				}
			} catch (e) {
				console.error("Lỗi parse JsonTime:", e);
				return;
			}
		}
		if (timeData && Array.isArray(timeData) && timeData.length > 0) {
			// Fill thời gian đầu tiên vào ô chính
			var firstTime = timeData[0];
			// Sử dụng TypeCheckInCheckOut và Time từ dữ liệu thực tế
			var selectInout = document.getElementById("select_inout");
			var timeInOut = document.getElementById("TimeInOut");
			if (selectInout && timeInOut) {
				selectInout.value = firstTime.TypeCheckInCheckOut || "1";
				var timeValue = firstTime.Time ? firstTime.Time.substring(0, 5) : "";
				timeInOut.value = timeValue;
			}
			// Tự động tạo và fill các ô thời gian bổ sung với trạng thái readonly
			for (var i = 1; i < timeData.length; i++) {
				var timeItem = timeData[i];
				// Tạo thêm ô thời gian bổ sung với trạng thái readonly
				addExtraTimeField(timeItem.TypeCheckInCheckOut, timeItem.Time, isFormInReadOnlyMode);
			}
		}
	}

	var isFormInReadOnlyMode = false;
// Hàm tạo ô thời gian bổ sung với dữ liệu có sẵn
	function addExtraTimeField(inoutType, timeValue, isReadOnly = false) {
		var extraTimeFields = document.getElementById(''extra-time-fields'');
		if (!extraTimeFields) {
			console.error("Không tìm thấy element extra-time-fields");
			return;
		}
		var currentTimeFields = extraTimeFields.querySelectorAll(''.time-entry'');
		if (currentTimeFields.length < 7) {
			var newTimeField = document.createElement(''div'');
			newTimeField.className = ''mb-2 time-entry'';
			var index = currentTimeFields.length;
			newTimeField.innerHTML = `
				<div class="row" data-index="${index}">
					<div class="to_day2">
						<label for="select_inout_${index}" class="col-sm-2 col-form-label">
							<span class="bi bi-door-open-fill me-1"></span>%CheckinOut% (*)</label>
						<div class="col-sm-4">
							<div class="d-flex">
								<select style="width: 100%;" class="form-control select-inout" id="select_inout_${index}" ${isReadOnly ? ''disabled'' : ''''}>
									<option value="1" id="In">%Status_In%</option>
									<option value="2" id="Out">%Status_Out%</option>
								</select>
							</div>
						</div>
					</div>
					<div class="to_day2">
						<label for="extraTime_${index}" class="col-sm-2 col-form-label"><span class="bi bi-calendar3 me-1"></span>%Time% (*)</label>
						<div class="col-sm-4 d-flex">
							<input type="time" class="form-control extra-time" id="extraTime_${index}" style="width:85%;" ${isReadOnly ? ''disabled'' : ''''}>
						</div>
					</div>
				</div>
			`;
			extraTimeFields.appendChild(newTimeField);
			// Set giá trị cho select và input
			var selectElement = document.getElementById(`select_inout_${index}`);
			var timeElement = document.getElementById(`extraTime_${index}`);
			if (selectElement && timeElement) {
				selectElement.value = inoutType || "1";
				var formattedTime = timeValue ? timeValue.substring(0, 5) : "";
				timeElement.value = formattedTime;
			}
		}
	}

//Chuyển các ô cần chuyển sang dạng chỉ đọc
	function setFormReadOnly(isReadOnly) {
		// Cập nhật biến global
		isFormInReadOnlyMode = isReadOnly;
		if (isReadOnly) {
			clearAllValidationErrors();
			$("#isSoftwareError").prop("disabled", true);
			// Disable các input chính
			$("#AttDate, #select_inout, #TimeInOut, #Note").prop("disabled", true);
			// Disable tất cả các ô thời gian bổ sung
			var extraTimeFields = document.getElementById("extra-time-fields");
			if (extraTimeFields) {
				var allSelects = extraTimeFields.querySelectorAll(''select[id^="select_inout_"]'');
				var allTimeInputs = extraTimeFields.querySelectorAll(''input[id^="extraTime_"]'');
				var selectsByClass = extraTimeFields.querySelectorAll(''.select-inout'');
				var inputsByClass = extraTimeFields.querySelectorAll(''.extra-time'');
				// Disable tất cả
				[...allSelects, ...selectsByClass].forEach(select => {
					select.disabled = true;
				});
				[...allTimeInputs, ...inputsByClass].forEach(input => {
					input.disabled = true;
				});
			}
			$("#add-time, #customchosefileMakeupHours").hide(); // Ẩn nút thêm thời gian và nút chọn file
			$("#sp_MakeupHours .btnRegister").addClass("d-none");// Ẩn nút Submit		
			$("#NtBeta-FileForMakeupHours").prop("disabled", true); // Disable input file
			$("#NtBeta-FilePreviewContainer .btn-remove-file").hide(); // Ẩn nút xóa file trong preview
		} else {
			$("#AttDate, #select_inout, #TimeInOut, #Note").prop("disabled", false); // Enable lại các input chính
			// Enable lại tất cả các ô thời gian bổ sung
			var extraTimeFields = document.getElementById("extra-time-fields");
			$("#isSoftwareError").prop("disabled", false);
			if (extraTimeFields) {
				var allSelects = extraTimeFields.querySelectorAll(''select[id^="select_inout_"]'');
				var allTimeInputs = extraTimeFields.querySelectorAll(''input[id^="extraTime_"]'');
				var selectsByClass = extraTimeFields.querySelectorAll(''.select-inout'');
				var inputsByClass = extraTimeFields.querySelectorAll(''.extra-time'');
				// Enable tất cả
				[...allSelects, ...selectsByClass].forEach(select => {
					select.disabled = false;
				});
				[...allTimeInputs, ...inputsByClass].forEach(input => {
		 input.disabled = false;
				});
			}
			$("#add-time, #customchosefileMakeupHours").show();
			$("#sp_MakeupHours .btnRegister").removeClass("d-none"); // Hiện lại các nút
			$("#NtBeta-FileForMakeupHours").prop("disabled", false); // Enable input file
			$("#NtBeta-FilePreviewContainer .btn-remove-file").show(); // Hiện lại nút xóa file trong preview
		}
	}

		$(document).ready(function() {
			// Xóa các event listener phức tạp cho modal
			$(''#filePreviewModal .modal-close'').off("click").on(''click'', function() {
				$(''#filePreviewModal'').hide();
			});
			$(''#filePreviewModal'').off("click").on(''click'', function(e) {
				if (e.target === this) {
					$(this).hide();
				}
			});
		});

// Thêm CSS động cho viền đỏ
	var style = document.createElement(''style'');
	style.textContent = `
		.required-error {
			border: 1px solid red !important;
		}
	`;
	document.head.appendChild(style);

//Hàm xử lí nút quay lại
	function handleBackButton() {
		// Kiểm tra nếu đang ở chế độ xem thông tin đơn duyệt
		if (sp_MakeupHours_param.IdentityID) {
			goBackFromMenu(''Overtime_Assignment_web'');
		// // Kiểm tra nếu đang ở chế độ xem chi tiết đơn
		} else if ($("#AttDate").prop("disabled")) {
			goBackFromMenu(''Overtime_Assignment_web'');
		} else {
			// Đang ở chế độ bình thường → quay về menu chính
			goBackFromMenu(''Overtime_Assignment_web'');
		}
	}

	async function fetchImageAsBase64(url) {
		try {
			if (!url || url === "") {
				return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
			}
			if (!url.startsWith(''http'') && !url.startsWith(''data:image'')) {
				return `data:image/jpeg;base64,${url}`;
			}
			if (url.startsWith(''http'')) {
				var response = await fetch(url, { method: ''GET'' });
				if (!response.ok) {
					console.error(`Lỗi khi lấy ảnh từ ${url}: ${response.statusText}`);
					return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
				}
				var blob = await response.blob();
				return new Promise((resolve, reject) => {
					var reader = new FileReader();
					reader.onloadend = () => resolve(reader.result);
					reader.onerror = reject;
					reader.readAsDataURL(blob);
				});
			}
			return url;
		} catch (err) {
			console.error(`Lỗi khi xử lý ảnh từ ${url}:`, err);
			return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
		}
	}

// Render danh sách file đã chọn ra UI theo giao diện preview dạng thẻ.
	function ntBetaAddFileUi(files, sender = 0) {
		const previewContainer = $("#NtBeta-FilePreviewContainer");
		previewContainer.empty();
		var isHidenRemoveFile = ""

		if (sender == 1) isHidenRemoveFile = "d-none"
		files.forEach((file, index) => {
			var fileName = file.fileName;

			// XỬ LÝ TÊN FILE GIỐNG CODE 1
			if(file.UrlFile) {
				// Lấy tên file từ UrlFile, xử lý cả \ và /
				var pathParts = file.UrlFile.split(/[\\\/]/);
				fileName = pathParts[pathParts.length - 1];
			}

			// Clean tên file bằng hàm sanitizeFileName
			fileName = sanitizeFileName(fileName);

			// Lấy extension từ tên file đã được clean
			const extension = fileName.split(''.'').pop().toLowerCase();
			let iconClass = "bi bi-file-earmark";
			let coloricon = "rgb(156, 163, 175)";
			let isImage = false;
			if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].includes(extension)) {
				iconClass = "bi bi-image";
				coloricon = "rgb(59, 130, 246)";
				isImage = true;
			} else if (["mp4", "mov", "avi", "mkv", "webm"].includes(extension)) {
				iconClass = "fa-file-video";
				coloricon = "rgb(220, 38, 38)";
			} else if (extension === "pdf") {
				iconClass = "bi bi-filetype-pdf";
				coloricon = "rgb(220, 38, 38)";
			} else if (["doc", "docx"].includes(extension)) {
				iconClass = "bi bi-file-word";
				coloricon = "rgb(30, 64, 175)";
			} else if (["xls", "xlsx", "csv"].includes(extension)) {
				iconClass = "bi bi-file-earmark-spreadsheet-fill";
				coloricon = "rgb(25, 135, 84)";
			} else if (["txt", "md", "log"].includes(extension)) {
				iconClass = "bi bi-file-text";
				coloricon = "rgb(107, 114, 128)";
			}

			const fileItem = $(`
				<div class="list-file active delete-file" data-index="${index}">
					<div class="hr-employee-item" style="border-left-color: #ffffff;">
						<div class="file-info">
							<span class="hr-badge" style="font-size:15px;">
								<i class="fas ${iconClass}" style="font-size:20px;color:${coloricon};"></i>
							</span>
							<div class="hr-employee-content">
								<div class="hr-employee-name preview-image" style="cursor:pointer">${fileName}</div>
							</div>
						</div>
						<span class="hr-badge btn-remove-file rounded-2 p-1 ${isHidenRemoveFile}" style="fs-6; background-color: #e3f2fd; color: #2196f3; cursor:pointer;">
							<i class="bi bi-trash"></i>
						</span>
					</div>
				</div>
			`);

			// Click xóa
			fileItem.find(".btn-remove-file").on("click", function () {
				const index = fileItem.data("index");
				ntBetaJsonFilesSelected.splice(index, 1);
				ntBetaAddFileUi(ntBetaJsonFilesSelected); // render lại
			});

			// Click xem file - SỬ DỤNG HÀM getFileQlbeta GIỐNG CODE 1
			fileItem.find(".preview-image").on("click", function () {
				const base64 = file.data;
				showLoadingByClassOrID("#sp_MakeupHours", "Loading...", "Black", "Black");
				getFileQlbeta(base64, fileName, isImage, sender)
				HideLoadingByClassOrID("#sp_MakeupHours");
			});
			previewContainer.append(fileItem);
		});
	}

// Xử lý sự kiện khi người dùng chọn file upload
	$(''#NtBeta-FileForMakeupHours'').off("change").on("change", async function (e) {
		const files = e.target.files;
		let promises = [];
		$.each(files, function (i, file) {
			const reader = new FileReader();
			promises.push(new Promise((resolve, reject) => {
				reader.onload = async function (e) {
					const base64Data = e.target.result.split('','')[1];
					const optimized = await optimizeImageBase64IfNeeded({
						fileName: file.name,
						data: base64Data
					});
					optimized.uid = Date.now() + ''_'' + i;
					ntBetaJsonFilesSelected.push(optimized);
					resolve();
				};
				reader.onerror = reject;
				reader.readAsDataURL(file);
			}));
		});
		await Promise.all(promises);
		ntBetaAddFileUi(ntBetaJsonFilesSelected);
		HideLoadingByClassOrID()
	});

//Tối ưu base64 cho file ảnh nếu vượt quá kích thước cho phép
	function optimizeImageBase64IfNeeded(fileObj, maxWidth = 1280, maxHeight = 1280, quality = 0.8) {
			return new Promise((resolve, reject) => {
				const extension = fileObj.fileName.split(''.'').pop().toLowerCase();
				const isImage = ["jpg", "jpeg", "png", "bmp", "webp"].includes(extension);
				if (!isImage) {
					// Không phải ảnh thì không tối ưu
					return resolve(fileObj);
				}
				const img = new Image();
				img.src = "data:image/*;base64," + fileObj.data;
				img.onload = function () {
					let width = img.width;
					let height = img.height;
					// Resize nếu cần
					if (width > maxWidth || height > maxHeight) {
						const ratio = Math.min(maxWidth / width, maxHeight / height);
						width = width * ratio;
						height = height * ratio;
					}
					const canvas = document.createElement("canvas");
					canvas.width = width;
					canvas.height = height;
					const ctx = canvas.getContext("2d");
					ctx.drawImage(img, 0, 0, width, height);
					const compressedDataUrl = canvas.toDataURL("image/jpeg", quality);
					const base64Data = compressedDataUrl.split('','')[1];
					resolve({
						fileName: fileObj.fileName,
						data: base64Data
					});
				};
				img.onerror = reject;
			});
		}

// Khi click vào vùng nền modal → ẩn modal
	$(''#ntbeta-image-modal'').off("click").on(''click'', function () {
		$(this).fadeOut();
	});

// Khi click vào ảnh → không đóng
	$(''#ntbeta-image-modal-img'').off("click").on(''click'', function (e) {
		e.stopPropagation(); // Ngăn click từ ảnh lan ra modal
	});

// Hàm xử lí ẩn hiện của từng modal
	function HideModalRemake() {
		$("#btnApproveModalRemake, #btnRejectModalRemake, #btnCancelModalRemake")
			.removeAttr("data-action")
			.prop("disabled", false)
			.find(".fa-spin").remove();
		if ($("#btnApproveModalRemake").hasClass("btn-success")) {
			$("#btnApproveModalRemake").removeClass("btn-success")
		} else if ($("#btnApproveModalRemake").hasClass("btn-danger")) {
			$("#btnApproveModalRemake").removeClass("btn-danger")
		} else if ($("#btnRejectModalRemake").hasClass("btn-success")) {
			$("#btnRejectModalRemake").removeClass("btn-success")
		} else {
			$("#btnRejectModalRemake").removeClass("btn-danger")
		}
		$(''#modalApproveAttendanceRequest'').modal(''hide'');
		$(''#modalRejectAttendanceRequest'').modal(''hide'');
		$(''#modalCancelAttendanceRequest'').modal(''hide'');
		$("#approveRemakeForExpenses").val("")
		$("#ghiChuNguoiDuyet2").val("");
		$("#remake").val("");
		$("#NoteCancel").val("");
	}

// Hàm kiểm tra cấp duyệt để duyệt đơn hiện tại và hiển thị nút
	function checkApprovalPermission(identityID) {
		AjaxHPAParadise({
			data: {
				name: "sp_CheckApprovalPermission",
				param: [
					"IdentityID", identityID,
					"LoginID", UserID
				]
			},
			success: function(result) {
				try {
					var data = JSON.parse(result).data[0];
					if (data[0].Approve_Status === 1 && data[0].Approve_StatusRequest === 1) {
						// Người dùng có quyền duyệt, hiển thị nút
						$("#sp_MakeupHours .btnApprove").removeClass("d-none");
						$("#sp_MakeupHours .btnReject").removeClass("d-none");
						$("#sp_MakeupHours .btnApprove").off("click").on("click",function(){
							$("#btnApproveModalRemake").attr("data-action", "approve");
							$("#btnApproveModalRemake").text("%IsApproval%");
							$("#btnApproveModalRemake").addClass("btn btn-success");
							$("#modalApproveAttendanceRequest").modal(''show'')		
						})
						$("#sp_MakeupHours .btnReject").off("click").on("click",function(){
							$("#btnApproveModalRemake").attr("data-action", "reject");
							$("#btnApproveModalRemake").text("%Deny%");
							$("#btnApproveModalRemake").addClass("btn btn-danger");
							$("#modalApproveAttendanceRequest").modal(''show'')			
						})
					} else if (data[0].Approve_Status === 1 && data[0].Approve_StatusRequest === 5) {
						$("#sp_MakeupHours .btnApprove").removeClass("d-none");
						$("#sp_MakeupHours .btnReject").removeClass("d-none");
						$("#sp_MakeupHours .btnApprove").off("click").on("click",function(){
							$("#btnRejectModalRemake").attr("data-action", "approve");
							$("#btnRejectModalRemake").text("%IsApproval%");
							$("#btnRejectModalRemake").addClass("btn btn-success");
							$("#modalRejectAttendanceRequest").modal(''show'')		
						})
						$("#sp_MakeupHours .btnReject").off("click").on("click",function(){
							$("#btnRejectModalRemake").attr("data-action", "reject");
							$("#btnRejectModalRemake").text("%Deny%");
							$("#btnRejectModalRemake").addClass("btn btn-danger");
							$("#modalRejectAttendanceRequest").modal(''show'')		
						})
					} else {
						// Không có quyền, không khớp LoginID, hoặc chưa đến lượt duyệt
						$("#sp_MakeupHours .btnApprove").addClass("d-none");
						$("#sp_MakeupHours .btnReject").addClass("d-none");
					}
				} catch (error) {
					$("#sp_MakeupHours .btnApprove").addClass("d-none");
				}
			},
			error: function(error) {
				$("#sp_MakeupHours .btnApprove").addClass("d-none");
				$("#sp_MakeupHours .btnReject").addClass("d-none");
			}
		});
	}

// Hàm xử lý phê duyệt đuyệt đơn
	function ApproveAttendanceRequest(identityID) {
		var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
		var checkInOutType = document.getElementById("select_inout").value;
		var timeInOut = document.getElementById("TimeInOut").value;
		var extraTimeFields = document.querySelectorAll("#extra-time-fields .row");
		var additionalTimes = [];
		extraTimeFields.forEach(row => {
			var inout = row.querySelector(".select-inout").value;
			var time = row.querySelector("input[type=''time'']").value;
			additionalTimes.push({ inout, time });
		});
		var allTimeData = [
			{ inout: checkInOutType, time: timeInOut },
			...additionalTimes
		];
		var jsonTime = JSON.stringify(allTimeData);
		AjaxHPAParadise({
			data: {
				name: "sp_ApproveAttendanceRequest",
				param: ["IdentityID", identityID,
					"LoginID", UserID,
					"Remark", Remark,
					"JsonTime", jsonTime]
			},
			success:async function(result) {
				showNotification("%lblSuc%", "%ApproveSuccess%", "success");
				//LuonNQ nếu có đơn pending thì set currentidentityID r chạy như thường
                let requestpendding = await GetAttdanceRequestPendding()
                if(requestpendding.length != 0)
                {
					Current_IdentityID = requestpendding[0].IdentityID
					InitdanceRequestPendding(requestpendding)
				}
				LoadAttendanceInformation(Current_IdentityID)
				setFormReadOnly(true);
				$("#sp_MakeupHours .btnRegister").addClass("d-none");
				HideModalRemake()
			},
			error: function(err) {
				showNotification("%lblerror%", "%ApproveFailed%", "error");
				$("#btnApproveModalRemake").prop("disabled", false).find(".fa-spin").remove();
			}
		});
	}

// Hàm xử lý từ chối duyệt đơn
	function RejectAttendanceRequest(identityID) {
		var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
		AjaxHPAParadise({
			data: {
				name: "sp_RejectAttendanceRequest",
				param: ["IdentityID", identityID,
						"LoginID", UserID,
						"Reason", Remark]
			},
			success:async function(result) {
				showNotification("%lblSuc%", "%RejectSuccess%", "success");
				//LuonNQ nếu có đơn pending thì set currentidentityID r chạy như thường
                let requestpendding = await GetAttdanceRequestPendding()
                if(requestpendding.length != 0)
                {
					Current_IdentityID = requestpendding[0].IdentityID
					InitdanceRequestPendding(requestpendding)
				}
				LoadAttendanceInformation(Current_IdentityID)
				checkApprovalPermission(Current_IdentityID);
				setFormReadOnly(true);
				$("#sp_MakeupHours .btnRegister").addClass("d-none");
				HideModalRemake()
			},
			error: function(err) {
				showNotification("%lblerror%", "%CannotRejectRequest%", "error");
			}
		});
	}

// Hàm xử lí nút phê duyệt cho đơn
	function HandleApproveAttendanceRequest() {
		const $btn = $("#btnApproveModalRemake");
		if ($btn.prop("disabled")) return; // Ngăn click nếu đã đang xử lý
		$btn.prop("disabled", true).append('' <i class="fa fa-spinner fa-spin"></i>'');
		var dataaction = $btn.attr("data-action");
		if (!dataaction) return;
		if (dataaction === ''reject'') {
			RejectAttendanceRequest(Current_IdentityID);
		} else {
			ApproveAttendanceRequest(Current_IdentityID);
		}
	}

	// Hàm xử lí nút phê duyệt (Approve/Reject cho yêu cầu HỦY)
	function HandleRejectAttendanceRequest() {
		const $btn = $("#btnRejectModalRemake");
		if ($btn.prop("disabled")) return;
		$btn.prop("disabled", true).append('' <i class="fa fa-spinner fa-spin"></i>'');
		var dataaction = $btn.attr("data-action");
		if (!dataaction) return;
		if (dataaction === ''reject'') {
			RejectCancelAttendanceRequest(Current_IdentityID);
		} else {
			ApproveCancelAttendanceRequest(Current_IdentityID);
		}
	}

// Hàm kiểm tra để hiển thị nút hủy đơn
	function checkCancelPermission(identityID) {
		AjaxHPAParadise({
			data: {
				name: "sp_CheckCancelPermission",
				param: [
					"IdentityID", identityID,
					"LoginID", UserID
				]
			},
			success: function(result) {		
				var data = JSON.parse(result).data[0];
				var lengthdata = data.length
				console.log(lengthdata)
				if (lengthdata >= 1) {
					// Người dùng có quyền hủy đơn, hiển thị nút
					$("#sp_MakeupHours .btnDestroy").removeClass("d-none");
					$("#sp_MakeupHours .btnDestroy").off("click").on("click",function(){
						$("#btnActionModalRemake").attr("data-action", "approve");
						$("#btnActionModalRemake").text("%IsApproval%");
						$("#btnActionModalRemake").addClass("btn btn-success");
						$("#modalCancelAttendanceRequest").modal(''show'')		
					})					
				} else {
					// Không có quyền, không khớp LoginID, hoặc chưa đến lượt duyệt
					$("#sp_MakeupHours .btnDestroy").addClass("d-none");
				}	
			},
			error: function(error) {
				$("#sp_MakeupHours .btnDestroy").addClass("d-none");
			}
		});
	}

// Hàm gửi yêu cầu hủy đơn
	function SentCancelAttendanceRequest(identityID) {
		var reason = document.getElementById("NoteCancel").value;
		AjaxHPAParadise({
			data: {
				name: "sp_SentCancelAttendanceRequest",
				param: ["IdentityID", identityID,
						"Reason", reason]
			},
			success: function(result) {
				showNotification("%lblSuc%", "%SubmitCancelRequestSuccess%", "success");
				LoadAttendanceInformation(identityID)
				checkApprovalPermission(identityID);
				setFormReadOnly(true);
				$("#sp_MakeupHours .btnRegister").addClass("d-none");
				HideModalRemake();
			}
		})
	}

// Hàm xử lí hủy đơn
	function HandleCancelAttendanceRequest () {
		var reason = document.getElementById("NoteCancel").value;
		// Kiểm tra xem lý do có được nhập hay không
		if (!reason || reason.trim() === '''') {	
			showNotification("%lblerror%", "Vui lòng nhập lý do hủy đơn", "error"); // Hiển thị thông báo lỗi
			document.getElementById("NoteCancel").style.border = "1px solid red";
			document.getElementById("NoteCancel").focus();
			return; // Dừng thực hiện nếu chưa nhập lý do
		}
		const $btn = $("#btnCancelModalRemake");
		if ($btn.prop("disabled")) return;
		$btn.prop("disabled", true).append('' <i class="fa fa-spinner fa-spin"></i>'');
		document.getElementById("NoteCancel").style.border = ""; // Xóa viền đỏ nếu đã nhập
		SentCancelAttendanceRequest(Current_IdentityID);
	}

// Hàm phê duyệt hủy đơn
	function ApproveCancelAttendanceRequest(identityID) {
		var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
		AjaxHPAParadise({
			data: {
				name: "sp_ApproveAttendanceRequest",
				param: ["IdentityID", identityID,
						"LoginID", UserID,
						"Remark", Remark]
			},
			success:async function(result) {
				showNotification("%lblSuc%", "%ApproveCancelRequest%", "success");
				//LuonNQ nếu có đơn pending thì set currentidentityID r chạy như thường
                let requestpendding = await GetAttdanceRequestPendding()
                if(requestpendding.length != 0)
                {
					Current_IdentityID = requestpendding[0].IdentityID
					InitdanceRequestPendding(requestpendding)
				}
				LoadAttendanceInformation(Current_IdentityID)
				checkApprovalPermission(Current_IdentityID);
				setFormReadOnly(true);
				$("#sp_MakeupHours .btnRegister").addClass("d-none");
				HideModalRemake()
			},
			error: function(err) {
				showNotification("%lblerror%", "%ErrorCancelRequest%", "error");
			}
		});
	}

// Hàm từ chối phê duyệt hủy đơn
	function RejectCancelAttendanceRequest(identityID) {
		var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
		AjaxHPAParadise({
			data: {
				name: "sp_RejectAttendanceRequest",
				param: ["IdentityID", identityID,
						"LoginID", UserID,
						"Reason", Remark]
			},
			success:async function(result) {
				showNotification("%lblSuc%", "%SuccessCancelRequest%", "success");
				//LuonNQ nếu có đơn pending thì set currentidentityID r chạy như thường
                let requestpendding = await GetAttdanceRequestPendding()
                if(requestpendding.length != 0)
                {
					Current_IdentityID = requestpendding[0].IdentityID
					InitdanceRequestPendding(requestpendding)
				}
				LoadAttendanceInformation(Current_IdentityID)
				checkApprovalPermission(Current_IdentityID);
				setFormReadOnly(true);
				$("#sp_MakeupHours .btnRegister").addClass("d-none");
				HideModalRemake()
			},
			error: function(err) {
				showNotification("%lblerror%", "%RejectCancelRequest%", "error");
			}
		});
	}

	function clearAllValidationErrors() {
		document.querySelectorAll(''.required-error'').forEach(field => {
			field.classList.remove(''required-error'');
		});
	}

//Các hàm được gọi
	function initMakeupHours() {
		DevexpressDesign();
		start();
		getTimelineqlbeta("", 5, "container_approval_process", "employeeDetailInfo");
		intitLoadRequest()
	}
	async function InitdanceRequestPendding(requestpendding)
	{
		if(!requestpendding)
		{
		 requestpendding = await GetAttdanceRequestPendding()
		}		
		 let dataRequest = requestpendding.filter(x => x.IdentityID != Current_IdentityID);

		RenderHtmlAttRequest(dataRequest)
		LoadImageAttRequestPendding()
	}
	//LuongNQ thêm tính lăng
	async function GetAttdanceRequestPendding()
	{
			var result =  await AjaxHPAParadiseAsync({
				data: {
						name: "sp_Attendance_PenddingRequest",
						param: ["LanguageID", LanguageID, "LoginID", UserID]
					},
					success: function (result) {
					}
			});
		return JSON.parse(result).data[0]
	}
	function RenderHtmlAttRequest(arr){
                if(!arr || arr.length == 0){
                    $("#container-penddingrequestAtt").addClass("d-none")
                }
                else{
					$("#container-penddingrequestAtt").removeClass("d-none")
                    $("#AttendRequestPendding").empty()
                    var html=""
                    arr.forEach(e => {
						html += `<div class="d-flex align-items-center gap-3 pb-3 pt-3 border-bottom">
                                    <img data-employee-id="${e.EmployeeID}" loading="lazy" class="request-avatar-img">
                                     <div class="heheeh">
                                        <div style="font-size:18px;">${e.FullName}</div>
										<div  style="font-size:14px;" class="d-flex align-items-center gap-1 fw-bold mb-2">
                                           ${e.AttDate}
                                        </div>
                                        <div class="d-flex align-items-center gap-1 text-primary fw-bold">
                                           ${e.ViewTime}
                                        </div>									
                                   </div>
                                 </div>`
					 });
                    $("#AttendRequestPendding").append(html)
                    //LoadImageAttdanceRequestPendding()
                }
            }
		async function LoadImageAttRequestPendding(){
    if($("#AttendRequestPendding img").length === 0) return;
    
    // Tối ưu: Dùng hàm gom gọi ảnh chung của hệ thống để không bị spam API
    if (typeof window.callImg === "function") {
        await window.callImg("#AttendRequestPendding img");
    }
}
		initMakeupHours()
</script>
</html>
    ';
	SELECT @html as html
	--exec sp_GenerateHTMLScript_new 'sp_MakeupHours_html'
END
