<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="TemplateCreate.aspx.cs" Inherits="SigningFormGenerator.TemplateCreate" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div id="TemplateEdit">
        <asp:HiddenField ID="TemplateID" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="UploadedPdfUrl" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="Mode" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="pdfUrl" runat="server" ClientIDMode="Static" />
        <label>Template Name</label>
        <input type="text" id="TemplateName" class="form-control" runat="server" ClientIDMode="Static" />

        <h2>Create PDF Template</h2>
        <asp:FileUpload ID="TemplateUpload" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Upload" OnClick="UploadButton_Click" CssClass="btn btn-primary mt-2" />

        <hr />

        <div id="field-tools" class="mt-3">
            <button type="button" class="btn btn-secondary" id="addInputField">Add Input Field</button>
            <button type="button" class="btn btn-secondary" id="addSignatureField">Add Signature Field</button>
            <button type="button" class="btn btn-danger" id="clearFields">Clear Fields</button>
            <button type="button" class="btn btn-primary" id="saveFields" runat="server">Save</button>
            <button type="button" class="btn btn-primary" id="btn_UpdateFields" runat="server">Update</button>
        </div>

        <hr />

        <div id="pdf-container" class="border">
            <!-- PDF rendering -->
            <canvas id="pdfCanvas" class="responsive"></canvas>
            <div id="fieldOverlay"></div>
            <!-- created fields -->
        </div>
    </div>

    <script>
        $(document).ready(function () {
            var savedFields = [];
            var pdfDoc = null;
            var pdfContainer = $("#pdf-container");
            var fieldCounters = {
                TextBox: 0,
                signature: 0
            };

            var activeSignatureBox = null;
            var currentPageNumber = 1;  // Track the currently focused page
            var mouseX = 0; // To store mouse X position
            var mouseY = 0; // To store mouse Y position
            var isPlacingInput = false; // Flag to check if we're in the process of placing an input
            var inputPreview; // Store the preview element
            var inputType = ""; // Store the type of input being placed

            // Track mouse movement over the PDF container
            $("#pdf-container").mousemove(function (event) {
                if (isPlacingInput && inputPreview) {
                    var containerOffset = $(this).offset();
                    mouseX = event.pageX - containerOffset.left + $(this).scrollLeft();
                    mouseY = event.pageY - containerOffset.top + $(this).scrollTop();

                    // Move the preview element with the cursor
                    inputPreview.css({
                        left: mouseX + 'px',
                        top: mouseY + 'px',
                        display: 'block'
                    });
                }
            });

            // Function to initiate input placement
            function startInputPlacement(type) {
                isPlacingInput = true; // Start the process of placing the input field
                inputType = type;

                // Create a preview element that follows the mouse
                inputPreview = $('<div class="draggable-input-preview">' + (type === "TextBox" ? "Input Field" : "Signature") + '</div>');
                inputPreview.css({
                    position: 'absolute',
                    display: 'none',
                    border: '1px dashed #000',
                    padding: '5px',
                    backgroundColor: '#fff',
                    zIndex: 1000
                });

                $("#pdf-container").append(inputPreview);
            }

            // Start placing the input field
            $("#addInputField").click(function () {
                startInputPlacement("TextBox");
            });

            // Start placing the signature field
            $("#addSignatureField").click(function () {
                startInputPlacement("signature");
            });

            // Handle the click event to place the input field
            $("#pdf-container").click(function (event) {
                if (isPlacingInput) {
                    var $targetPage = $(event.target).closest('.pdfPage');

                    if ($targetPage.length) {
                        var pageNumber = $targetPage.data('page-number');

                        // Get offset within the page
                        var pageOffset = $targetPage.offset();

                        // The position is converted to percentages relative to the clicked page
                        var leftPercentage = ((event.pageX - pageOffset.left) / $targetPage.width()) * 100;
                        var topPercentage = ((event.pageY - pageOffset.top) / $targetPage.height()) * 100;

                        // Create the draggable input at the identified position
                        createDraggableInput(inputType, leftPercentage, topPercentage, pageNumber);

                        // Remove the preview element and reset the flag
                        inputPreview.remove();
                        inputPreview = null;
                        isPlacingInput = false;
                    }
                }
            });

            // Cancel input placement on right-click
            $(document).on('contextmenu', function (event) {
                if (isPlacingInput) {
                    inputPreview.remove();
                    inputPreview = null;
                    isPlacingInput = false;
                    event.preventDefault(); // Prevent the default context menu
                }
            });

            function renderSavedFields(savedFields) {
                $.each(savedFields, function (index, field) {
                    createDraggableInput(field.FieldType, field.LeftPosition, field.TopPosition, field.PageNumber, true);
                });
            }

            function renderPDF(url) {
                if (!url) {
                    console.error("Error: Invalid PDF URL.");
                    return;
                }

                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js';

                pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
                    pdfDoc = pdfDoc_;
                    pdfContainer.empty(); // Clear previous contents

                    for (var pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
                        pdfDoc.getPage(pageNum).then(function (page) {
                            var viewport = page.getViewport({ scale: 1 });
                            var canvas = document.createElement('canvas');
                            var context = canvas.getContext('2d');
                            canvas.height = viewport.height;
                            canvas.width = viewport.width;
                            canvas.className = "pdfCanvas";

                            var pdfPage = document.createElement('div');
                            pdfPage.className = "pdfPage card";
                            pdfPage.style.position = "relative";
                            pdfPage.setAttribute("data-page-number", page.pageNumber); // Store the page number
                            pdfPage.appendChild(canvas);

                            var fieldOverlay = document.createElement('div');
                            fieldOverlay.className = "fieldOverlay";
                            fieldOverlay.setAttribute("data-page-number", page.pageNumber);
                            pdfPage.appendChild(fieldOverlay);

                            pdfContainer.append(pdfPage);

                            page.render({ canvasContext: context, viewport: viewport }).promise.then(function () {
                                renderSavedFields(savedFields);
                            });

                            // Click event to set the focused page
                            pdfPage.addEventListener("click", function () {
                                currentPageNumber = page.pageNumber;
                                console.log("Focused page:", currentPageNumber);
                            });
                        });
                    }
                }).catch(function (error) {
                    console.error("Error loading PDF:", error);
                });
            }

            function createDraggableInput(type, leftPosition, topPosition, pageNumber, isRendering) {
                var fieldId = type + '_' + (++fieldCounters[type]);
                var wrapper = document.createElement("div");
                wrapper.className = "draggable-input-wrapper " + type;
                wrapper.style.left = leftPosition + "%";
                wrapper.style.top = topPosition + "%";

                if (type === "signature") {
                    var signatureBox = document.createElement("div");
                    signatureBox.className = "signature-box";
                    signatureBox.id = fieldId;
                    signatureBox.innerText = "Click here to sign";
                    wrapper.appendChild(signatureBox);
                } else {
                    var input = document.createElement("input");
                    input.type = "text";
                    input.id = fieldId;
                    input.className = "draggable-input";
                    input.placeholder = type;
                    wrapper.appendChild(input);
                }

                var deleteBtn = document.createElement("button");
                deleteBtn.className = "delete-btn";
                deleteBtn.innerText = "X";
                deleteBtn.onclick = function () {
                    wrapper.parentElement.removeChild(wrapper);
                    savedFields = savedFields.filter(field => field.ID !== fieldId);
                };

                wrapper.appendChild(deleteBtn);
                wrapper.setAttribute("draggable", "true");

                var pageOverlay = $(".fieldOverlay[data-page-number='" + pageNumber + "']");
                pageOverlay.append(wrapper);

                wrapper.addEventListener("dragstart", function (event) {
                    event.dataTransfer.setData("text/plain", null);
                    wrapper.style.opacity = "0.5";
                    event.dataTransfer.setDragImage(event.target, 0, 0);
                });

                wrapper.addEventListener("dragend", function (event) {
                    var pageOverlay = $(".fieldOverlay[data-page-number='" + pageNumber + "']");
                    var pageOverlayRect = pageOverlay[0].getBoundingClientRect();

                    // Calculate the position relative to the page overlay within the container
                    var left = ((event.clientX - pageOverlayRect.left) / pageOverlayRect.width) * 100;
                    var top = ((event.clientY - pageOverlayRect.top) / pageOverlayRect.height) * 100;

                    wrapper.style.left = left + "%";
                    wrapper.style.top = top + "%";
                    wrapper.style.opacity = "1";

                    if (!isRendering) {
                        updateFieldPosition(fieldId, left, top, pageNumber);
                    }
                });

                wrapper.addEventListener("drag", function (event) {
                    autoScroll(event);
                });
            }

            function autoScroll(event) {
                var containerRect = pdfContainer[0].getBoundingClientRect();
                var topThreshold = 100;
                var bottomThreshold = containerRect.height - 100;

                if (event.clientY < containerRect.top + topThreshold) {
                    pdfContainer.scrollTop(pdfContainer.scrollTop() - 20);
                } else if (event.clientY > containerRect.top + bottomThreshold) {
                    pdfContainer.scrollTop(pdfContainer.scrollTop() + 20);
                }
            }

            function updateFieldPosition(fieldId, leftPosition, topPosition, pageNumber) {
                var fieldIndex = findFieldIndexById(fieldId);
                if (fieldIndex !== -1) {
                    savedFields[fieldIndex].LeftPosition = leftPosition;
                    savedFields[fieldIndex].TopPosition = topPosition;
                    savedFields[fieldIndex].PageNumber = pageNumber;
                }
            }

            function findFieldIndexById(fieldId) {
                return savedFields.findIndex(field => field.ID === fieldId);
            }

            var pdfUrl = '<%= Session["UploadedPdfUrl"] %>';
            console.log("Loaded PDF URL:", pdfUrl);
            $("#UploadedPdfUrl").val(pdfUrl);
            $("#TemplateName").val('<%= Session["TemplateName"] %>');

            if (pdfUrl) {
                getSavedField(pdfUrl);
            } else {
                console.error("Error: PDF URL is missing or invalid.");
            }

            function getSavedField(pdfUrl) {
                var TID = $("#TemplateID").val();
                if (TID != null && TID != "") {
                    $.ajax({
                        url: 'TemplateCreate.aspx/GetSavedFields',
                        type: 'POST',
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        data: JSON.stringify({ TID: TID }),
                        success: function (response) {
                            savedFields = response.d;
                            renderSavedPDF(pdfUrl);
                        },
                        error: function (xhr, status, error) {
                            alert('Error retrieving saved fields: ' + error);
                        }
                    });
                } else {
                    renderPDF(pdfUrl);
                }
            }

            function renderSavedPDF(url) {
                if (!url) {
                    console.error("Error: Invalid PDF URL.");
                    return;
                }

                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js';
                pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
                    pdfDoc = pdfDoc_;
                    for (var pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
                        pdfDoc.getPage(pageNum).then(function (page) {
                            var viewport = page.getViewport({ scale: 1 });
                            var canvas = document.createElement('canvas');
                            var context = canvas.getContext('2d');
                            canvas.height = viewport.height;
                            canvas.width = viewport.width;
                            canvas.className = "pdfCanvas";

                            var pdfPage = document.createElement('div');
                            pdfPage.className = "pdfPage card";
                            pdfPage.setAttribute("data-page-number", page.pageNumber); // Store the page number
                            pdfPage.appendChild(canvas);

                            var fieldOverlay = document.createElement('div');
                            fieldOverlay.className = "fieldOverlay";
                            fieldOverlay.setAttribute("data-page-number", page.pageNumber);
                            pdfPage.appendChild(fieldOverlay);

                            pdfContainer.append(pdfPage);

                            page.render({ canvasContext: context, viewport: viewport }).promise.then(function () {
                                var savedFields_byPage = savedFields.filter(function (item) {
                                    return item.PageNumber === page.pageNumber;
                                });
                                renderSavedFields(savedFields_byPage);
                            });

                            // Click event to set the focused page
                            pdfPage.addEventListener("click", function () {
                                currentPageNumber = page.pageNumber;
                                console.log("Focused page:", currentPageNumber);
                            });
                        });
                    }
                }).catch(function (error) {
                    console.error("Error loading PDF:", error);
                });
            }

            $("#clearFields").click(function () {
                $(".draggable-input-wrapper").remove();
                savedFields = [];
            });

            $("#saveFields").click(function () {
                saveFieldsToDatabase();
            });

            $("#btn_UpdateFields").click(function () {
                UpdateFieldsToDatabase();
            });

            function saveFieldsToDatabase() {
                var pdfUrl = $("#UploadedPdfUrl").val();
                var mode = $("#Mode").val();
                var tempName = $("#TemplateName").val();

                savedFields = [];
                $(".draggable-input-wrapper").each(function () {
                    var $field = $(this);
                    var type = $field.find("input").length ? "TextBox" : "signature";
                    var left = parseFloat($field.css("left")) / $(this).closest(".fieldOverlay").width() * 100;
                    var top = parseFloat($field.css("top")) / $(this).closest(".fieldOverlay").height() * 100;
                    var PageNumber = parseInt($field.closest(".fieldOverlay").data("pageNumber"), 10);
                    var fieldId = $field.find("input").attr('id');
                    if (type === "signature") {
                        fieldId = $field.find(".signature-box").attr('id');
                    }
                    savedFields.push({ ID: fieldId, FieldType: type, LeftPosition: left, TopPosition: top, PageNumber: PageNumber });
                });

                $.ajax({
                    url: 'TemplateCreate.aspx/SaveFields',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    data: JSON.stringify({ fields: savedFields, pdfUrl: pdfUrl, mode: mode, templateName: tempName }),
                    success: function (response) {
                        alert('Fields saved successfully.');
                        window.location.href = "TemplateList.aspx";
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });
            }

            function UpdateFieldsToDatabase() {
                var pdfUrl = $("#UploadedPdfUrl").val();
                var mode = $("#Mode").val();
                var tempName = $("#TemplateName").val();
                var TID = $("#TemplateID").val();

                savedFields = [];

                $(".draggable-input-wrapper").each(function () {
                    var $field = $(this);
                    var type = $field.find("input").length ? "TextBox" : "signature";
                    var left = parseFloat($field.css("left")) / $(this).closest(".fieldOverlay").width() * 100;
                    var top = parseFloat($field.css("top")) / $(this).closest(".fieldOverlay").height() * 100;
                    var PageNumber = parseInt($field.closest(".fieldOverlay").data("pageNumber"), 10);
                    var fieldId = $field.find("input").attr('id');
                    if (type === "signature") {
                        fieldId = $field.find(".signature-box").attr('id');
                    }
                    savedFields.push({ ID: fieldId, FieldType: type, LeftPosition: left, TopPosition: top, PageNumber: PageNumber });
                });

                var signingList = {
                    TID: TID,
                    TemplateName: tempName,
                    fieldDatas: savedFields
                };
                console.log(signingList)
                $.ajax({
                    url: 'TemplateCreate.aspx/UpdateFields',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    data: JSON.stringify({ siging: signingList, pdfUrl: pdfUrl }),
                    success: function (response) {
                        alert('Fields Updated Successfully.');
                        window.location.href = "TemplateList.aspx";
                    },
                    error: function (xhr, status, error) {
                        console.error(xhr.responseText);
                    }
                });
            }
        });
    </script>
</asp:Content>
