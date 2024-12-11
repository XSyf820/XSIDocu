<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="ViewPdf.aspx.cs" Inherits="SigningFormGenerator.ViewPdf" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .ReadonlyMode {
            border: none;
        }

        .editable {
            border: none;
        }

        /* .editable {
              border: 2px dashed #FF2C2C;
              border: 2px dashed #FF2C2C;
            padding: 10px;
            cursor: move;
            text-align: center;
            font-size: 14px;
            font-weight: bold;
            position: relative;
        }*/
    </style>
  
    <asp:HiddenField ID="ProcessID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="TemplateID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="pdfUrl" runat="server" ClientIDMode="Static" />

   <div id="TemplateEdit">
                                            <h2>Signed PDF Template</h2>
                                            <span id="TemplateName" runat="server"></span>
                                            <%-- <asp:FileUpload ID="FileUpload12" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Upload" OnClick="UploadButton_Click" CssClass="btn btn-primary mt-2" />--%>
                                            <hr />
                                            <div id="pdf-container" class="border">
                                                <!-- PDF rendering -->
                                                <canvas id="pdfCanvas"></canvas>
                                                <div id="fieldOverlay"></div>
                                                <!-- created fields -->
                                            </div>
                                           <%-- <div id="field-tools" class="mt-3" style="display:none">
                                                <button id="downloadPdfBtn" class="btn btn-secondary" onclick="downloadPdfWithFields(event)">Submit PDF</button>

                                            </div>--%>
                                        </div>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/@pdf-lib/pdf-lib@1.16.0/dist/pdf-lib.js"></script>

    <script>
        // Initially disable the save button
        $('#save-signature').prop('disabled', true);


        $('#userConcentCheck').change(function () {
            if ($(this).is(':checked')) {
                // Enable the save button if the checkbox is checked
                $('#save-signature').prop('disabled', false);
            } else {
                // Disable the save button if the checkbox is unchecked
                $('#save-signature').prop('disabled', true);
            }
        });
        $(document).ready(function () {
            var pdfDoc = null;
            var pdfContainer = $("#pdf-container");
            var fieldOverlay = $("#fieldOverlay")[0];
            var savedFields = [];

            function renderSavedFields(savedFields) {
                $.each(savedFields, function (index, field) {
                    addEditableInput(field.FieldType, field.LeftPosition, field.TopPosition, field.Value, field.ID, field.IsEditable, field.PageNumber);
                });
            }


            //function addEditableInput(type, left, top, value, id, isEditable, PageNumber) {
            //    var readonly = "";
            //    if (!isEditable) {
            //        readonly = "ReadonlyMode";
            //    } else {
            //        readonly = "editable";
            //    }

            //    var input;


            //    if (type === "signature") {
            //        input = $("<div class='editable-input " + type + " signature-box " + readonly + "' data-id='" + id + "'>Click here to sign</div>").css({
            //            position: 'absolute',
            //            left: left + 'px',
            //            top: top + 'px',
            //            cursor: 'pointer'
            //        });

            //        input.on("click", function () {
            //            if (isEditable) {
            //                activeSignatureBox = this;
            //                $('#signature-pad').modal('show');
            //            }
            //        });

            //        if (value) {
            //            var img = new Image();
            //            img.onload = function () {
            //                var maxWidth = $(input).width();
            //                var maxHeight = $(input).height();
            //                var widthRatio = maxWidth / img.width;
            //                var heightRatio = maxHeight / img.height;
            //                var scale = Math.min(widthRatio, heightRatio);
            //                img.width *= scale;
            //                img.height *= scale;
            //                img.className = 'signature-image';
            //                $(input).empty().append(img);
            //            };
            //            img.src = value.replace('~/', ''); // Ensure the path is correct
            //            $(input).attr('data-signature-url', value);
            //        }



            //    } else {
            //        input = $("<input type='text' class='editable-input " + type + " " + readonly + "' placeholder='" + type + "' data-id='" + id + "' />").css({
            //            position: 'absolute',
            //            left: left + 'px',
            //            top: top + 'px',
            //        }).val(value);
            //    }

            //    input.appendTo(fieldOverlay);

            //    input.draggable({
            //        disabled: true
            //    });
            //}



            function addEditableInput(type, left, top, value, id, isEditable, PageNumber) {
                var readonly = isEditable ? " editable " : " ReadonlyMode ";
                console.log(readonly)
                //var fieldId = id || type + '_' + (++fieldCounters[type]);

                //// Create a wrapper for the draggable input
                //var wrapper = document.createElement("div");
                //wrapper.className = " draggable-input-wrapper  " + readonly + type;
                //wrapper.style.left = left + "px";
                //wrapper.style.top = top + "px";
                var fieldId = id;
                var wrapper = document.createElement("div");
                wrapper.className = "draggable-input-wrapper " + readonly + type;
                wrapper.style.left = left + "%";
                wrapper.style.top = top + "%";

                var input;
                var editable_className = "";
                if (isEditable) {
                    editable_className = " editable-input ";
                }
                if (type === "signature") {
                    // Create signature box
                    input = document.createElement("div");
                    input.className = editable_className + " signature-box  all-input " + type;
                    input.setAttribute("data-id", fieldId);
                    input.id = fieldId;
                    input.innerText = "Click here to sign";
                    input.style.cursor = isEditable ? 'pointer' : 'default';

                    // Attach click event for signing
                    input.addEventListener("click", function () {
                        if (isEditable) {
                            activeSignatureBox = input;
                            $('#signature-pad').modal('show');
                        }
                    });

                    // If a signature value exists, display it
                    if (value) {
                        var img = new Image();
                        img.onload = function () {
                            var maxWidth = input.clientWidth;
                            var maxHeight = input.clientHeight;
                            var widthRatio = maxWidth / img.width;
                            var heightRatio = maxHeight / img.height;
                            var scale = Math.min(widthRatio, heightRatio);
                            img.width *= scale;
                            img.height *= scale;
                            img.className = 'signature-image ';
                            input.innerHTML = ''; // Clear the text
                            input.appendChild(img);
                        };
                        img.src = value.replace('~/', '');
                        input.setAttribute('data-signature-url', value);
                    }

                    wrapper.appendChild(input);

                } else {
                    // Create a text input
                    input = document.createElement("input");
                    input.type = "text";
                    input.className = editable_className + " all-input " + readonly + " " + type;
                    input.placeholder = type;
                    input.value = value || "";
                    console.log(value)
                    input.id = fieldId;
                    input.setAttribute("data-id", fieldId);

                    wrapper.appendChild(input);
                }

                // Append the wrapper to the appropriate page overlay
                var pageOverlay = $(".fieldOverlay[data-page-number='" + PageNumber + "']");
                pageOverlay.append(wrapper);

                // Make the input draggable
                $(wrapper).draggable({
                    disabled: false,

                });


            }



            function updateFieldValueById(id, newValue) {
                $(".editable-input[data-id='" + id + "']").val(newValue);
            }

            var pdfUrl = $("#pdfUrl").val();
            var processid = $("#ProcessID").val();
            var TID = $("#TemplateID").val();

            $.ajax({
                url: 'SignForm.aspx/GetSavedFields',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ ProcessID: processid, TID: TID }),
                success: function (response) {
                    savedFields = response.d;
                    renderPDF(pdfUrl);
                },
                error: function (xhr, status, error) {
                    alert('Error retrieving saved fields: ' + error);
                }
            });

            function renderPDF(url) {
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

        });


        function readonly() {
            const readonlyFields = document.getElementsByClassName("ReadonlyMode");

            for (let i = 0; i < readonlyFields.length; i++) {
                readonlyFields[i].readOnly = true;
            }
        }




        const { PDFDocument, rgb } = PDFLib;

        async function downloadPdfWithFields() {
            try {
                await updateFieldsToDatabase();

                const pdfUrl = $("#pdfUrl").val(); // URL to the PDF file

                console.log("Fetching PDF from URL: ", pdfUrl);

                const response = await fetch(pdfUrl);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                console.log('PDF fetch response received');

                const pdfBytes = await response.arrayBuffer();
                console.log('PDF fetched successfully');

                const pdfDoc = await PDFDocument.load(pdfBytes);
                console.log('PDF loaded successfully');

                const pages = pdfDoc.getPages();
                const firstPage = pages[0];
                const { width, height } = firstPage.getSize();

                const editableInputs = $(".editable-input");

                for (const input of editableInputs) {
                    const $input = $(input);
                    const value = $input.val();
                    const left = parseFloat($input.css('left'));
                    const top = parseFloat($input.css('top'));

                    if ($input.hasClass("signature")) {
                        const signatureImg = $input.find('.signature-image');
                        if (signatureImg.length > 0) {
                            const src = signatureImg.attr('src');
                            console.log('Signature image src:', src);
                            if (src && (src.startsWith('http') || src.startsWith('https') || src.startsWith('SignedFiles/SignedImage/')
                                || src.startsWith('data:image/png'))) {
                                const img = await loadImage(src);

                                console.log('Image loaded successfully:', img.width, img.height);

                                // Get the dimensions of the .signature-box div
                                const maxWidth = $input.width();
                                const maxHeight = $input.height();

                                // Calculate scaling ratios
                                const widthRatio = maxWidth / img.width;
                                const heightRatio = maxHeight / img.height;
                                const scale = Math.min(widthRatio, heightRatio); // Scale by the minimum ratio to fit within the box

                                const imgWidth = img.width * scale;
                                const imgHeight = img.height * scale;
                                const imageType = getImageType(src);
                                console.log('Image type:', imageType);
                                // Draw the image on the PDF
                                let pdfImage;
                                if (imageType === 'png') {
                                    const imgBlob = await fetch(src).then(res => res.blob());
                                    pdfImage = await pdfDoc.embedPng(await imgBlob.arrayBuffer());

                                } else {
                                    pdfImage = await pdfDoc.embedPng(img.src);

                                }
                                firstPage.drawImage(pdfImage, {
                                    x: left,
                                    y: height - top - imgHeight, // Adjust Y position based on canvas vs PDF coordinates
                                    width: imgWidth,
                                    height: imgHeight,
                                });
                            } else {
                                console.error('Invalid or missing src attribute for signature image.');
                            }
                        }
                    } else {
                        firstPage.drawText(value, {
                            x: left,
                            y: height - top - 12, // Adjust Y position for text based on canvas vs PDF coordinates
                            size: 12,
                            color: rgb(0, 0, 0)
                        });
                    }
                }

                const updatedPdfBytes = await pdfDoc.save();
                console.log('PDF saved successfully');

                const formData = new FormData();
                const blob = new Blob([updatedPdfBytes], { type: 'application/pdf' });
                formData.append('pdfFile', blob);

                const serverResponse = await savePdfToServer(formData);
                console.log('Response from server:', serverResponse.d);
                alert('PDF saved successfully to SignedFiles folder.');

            } catch (error) {
                console.error('Error in downloadPdfWithFields:', error);
                alert('Error processing PDF: ' + error.message);
            }
        }

        function loadImage(src) {
            return new Promise((resolve, reject) => {
                const img = new Image();
                img.onload = () => resolve(img);
                img.onerror = reject;
                img.src = src;
            });
        }

        async function updateFieldsToDatabase() {
            return new Promise((resolve, reject) => {
                const pdfUrl = $("#pdfUrl").val();
                const savedFields = [];
                const guid = $("#TemplateID").val();
                const sid = $("#ProcessID").val();

                $(".editable-input").each(function () {
                    const input = $(this);
                    const id = input.attr('data-id');
                    const type = input.hasClass("TextBox") ? "TextBox" : input.hasClass("signature") ? "signature" : "custom";
                    let value = input.val();

                    const isReadonly = input.hasClass("ReadonlyMode");

                    if (!isReadonly) {
                        if (type === "signature") {
                            const signatureImg = input.find('.signature-image');
                            if (signatureImg.length > 0) {
                                const canvas = document.createElement('canvas');
                                canvas.width = signatureImg[0].width;
                                canvas.height = signatureImg[0].height;
                                const ctx = canvas.getContext('2d');
                                ctx.drawImage(signatureImg[0], 0, 0, signatureImg[0].width, signatureImg[0].height);
                                value = canvas.toDataURL();
                            }
                        }
                        savedFields.push({ ID: id, FieldType: type, Value: value, guid: guid, SID: sid });
                    }
                });
                const signing = {
                    TID: guid,
                    SID: sid,
                    fieldDatas: savedFields
                }

                $.ajax({
                    url: 'SignForm.aspx/UpdateFields',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    data: JSON.stringify({ siging: signing, pdfUrl: pdfUrl }),
                    success: function (response) {
                        console.log('Fields saved successfully.');
                        resolve(response);
                    },
                    error: function (xhr, status, error) {
                        console.error('Error saving fields:', error);
                        reject(new Error('Error saving fields: ' + error));
                    }
                });
            });
        }

        function savePdfToServer(formData) {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'POST',
                    url: 'SavePdfToServer.aspx',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        resolve(response);
                        window.location.href = "success.aspx"
                    },
                    error: function (xhr, status, error) {
                        console.error('Error saving PDF:', error);
                        reject(error);
                    }
                });
            });
        }


    </script>

    <script>
        $(document).ready(function () {

            var canvas = document.getElementById('canvas');
            var ctx = canvas.getContext('2d');
            ctx.strokeStyle = "#000";
            ctx.lineWidth = 2;
            var drawing = false;
            var mousePos = { x: 0, y: 0 };
            var lastPos = mousePos;

            canvas.addEventListener("mousedown", function (e) {
                drawing = true;
                lastPos = getMousePos(canvas, e);
            }, false);

            canvas.addEventListener("mouseup", function (e) {
                drawing = false;
            }, false);

            canvas.addEventListener("mousemove", function (e) {
                mousePos = getMousePos(canvas, e);
                renderCanvas();
            }, false);

            canvas.addEventListener("touchstart", function (e) {
                drawing = true;
                lastPos = getTouchPos(canvas, e);
            }, false);

            canvas.addEventListener("touchend", function (e) {
                drawing = false;
            }, false);

            canvas.addEventListener("touchmove", function (e) {
                mousePos = getTouchPos(canvas, e);
                renderCanvas();
            }, false);

            function getMousePos(canvasDom, mouseEvent) {
                var rect = canvasDom.getBoundingClientRect();
                return {
                    x: mouseEvent.clientX - rect.left,
                    y: mouseEvent.clientY - rect.top
                };
            }

            function getTouchPos(canvasDom, touchEvent) {
                var rect = canvasDom.getBoundingClientRect();
                return {
                    x: touchEvent.touches[0].clientX - rect.left,
                    y: touchEvent.touches[0].clientY - rect.top
                };
            }

            function renderCanvas() {
                if (drawing) {
                    ctx.beginPath();
                    ctx.moveTo(lastPos.x, lastPos.y);
                    ctx.lineTo(mousePos.x, mousePos.y);
                    ctx.stroke();
                    lastPos = mousePos;
                }
            }

            $("#clear-signature").click(function () {
                clearCanvas();
            });

            function clearCanvas() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
            }

            $("#save-signature").click(function () {
                saveSignature();
            });

            function saveSignature() {

                var signatureImg = canvas.toDataURL(); // Save the signature as a base64 encoded image
                var img = new Image();
                img.onload = function () {
                    var maxWidth = $(activeSignatureBox).width(); // Get the width of the signature box
                    var maxHeight = $(activeSignatureBox).height(); // Get the height of the signature box
                    var widthRatio = maxWidth / img.width;
                    var heightRatio = maxHeight / img.height;
                    var scale = Math.min(widthRatio, heightRatio); // Scale by the minimum ratio to fit within the box
                    img.width *= scale; // Scale the image width
                    img.height *= scale; // Scale the image height
                    $(activeSignatureBox).empty(); // Clear previous content in the signature box
                    img.className = 'signature-image';
                    activeSignatureBox.appendChild(img); // Append the scaled image

                    $('#signature-pad').modal('hide');
                    clearCanvas(); // Clear the canvas after saving
                };
                img.src = signatureImg; // Set the image source to trigger onload event
            }


        });
        function getImageType(src) {
            // Extract the file extension from the image source URL
            const extension = src.split('.').pop().toLowerCase();
            if (extension === 'png') {
                return extension;
            } else if (extension === 'jpg' || extension === 'jpeg') {
                return 'jpeg'; // Consider both JPG and JPEG as JPEG for PDF embedding
            }
            return null; // Invalid or unsupported image type
        }
    </script>




</asp:Content>
