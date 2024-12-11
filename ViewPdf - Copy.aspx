<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="ViewPdf.aspx.cs" Inherits="SigningFormGenerator.ViewPdf" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Sign PDF</h2>
    <asp:HiddenField ID="ProcessID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="TemplateID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="pdfUrl" runat="server" ClientIDMode="Static" />

    <div id="pdf-container" class="border" style="position: relative;">
        <canvas id="pdfCanvas"></canvas> <!-- Canvas for rendering PDF -->
        <div id="fieldOverlay" style="position: absolute; top: 0; left: 0;"></div> <!-- Overlay for draggable input fields -->
    </div>
  <%--  <button id="updateNameBtn" class="btn btn-primary" onclick="updateFieldsToDatabase()">Save</button>--%>
   <button id="downloadPdfBtn" class="btn btn-secondary" onclick="downloadPdfWithFields(event)">Download PDF</button>

     <!-- Signature Pad Modal -->
    <div class="modal fade" id="signature-pad" tabindex="-1" role="dialog" aria-labelledby="signature-pad-label" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="signature-pad-label">Sign Here</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <canvas id="canvas"></canvas>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="save-signature">Save</button>
                    <button type="button" class="btn btn-danger" id="clear-signature">Clear</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Signature Pad Modal end -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">

    <script>
        $(document).ready(function () {
            var pdfDoc = null;
            var pdfContainer = $("#pdf-container");
            var fieldOverlay = $("#fieldOverlay");
            var savedFields = [];

            function renderSavedFields(savedFields) {
                $.each(savedFields, function (index, field) {
                    addEditableInput(field.FieldType, field.LeftPosition, field.TopPosition, field.Value, field.ID, field.IsEditable);
                });
            }

         
            function addEditableInput(type, left, top, value, id, isEditable) {
                var readonly = "";
                if (!isEditable) {
                    readonly = "ReadonlyMode";
                }

                var input;
                console.log(type)
                if (type === "custom") 
                    {
                    input = $("<div class='editable-input " + type + " signature-box " + readonly + "' data-id='" + id + "'>Click here to sign</div>").css({
                        position: 'absolute',
                        left: left + 'px',
                        top: top + 'px',
                        cursor: 'pointer'
                    });

                    input.on("click", function () {
                        if (isEditable) {
                            activeSignatureBox = this;
                            $('#signature-pad').modal('show');
                        }
                    });

                    if (value) {
                        var img = new Image();
                        img.onload = function () {
                            var maxWidth = $(input).width();
                            var maxHeight = $(input).height();
                            var widthRatio = maxWidth / img.width;
                            var heightRatio = maxHeight / img.height;
                            var scale = Math.min(widthRatio, heightRatio);
                            img.width *= scale;
                            img.height *= scale;
                            $(input).empty().append(img);
                        };
                        img.src = value.replace('~/', ''); // Ensure the path is correct
                        $(input).attr('data-signature-url', value);
                    }



                } else {
                    input = $("<input type='text' class='editable-input " + type + " " + readonly + "' placeholder='" + type + "' data-id='" + id + "' />").css({
                        position: 'absolute',
                        left: left + 'px',
                        top: top + 'px',
                    }).val(value);
                }

                input.appendTo(fieldOverlay);

                input.draggable({
                    disabled: true
                });
            }

            function updateFieldValueById(id, newValue) {
                $(".editable-input[data-id='" + id + "']").val(newValue);
            }

            var pdfUrl = $("#pdfUrl").val();
            var processid = $("#ProcessID").val();
            var TID = $("#TemplateID").val();

            $.ajax({
                url: 'ViewPdf.aspx/GetSavedFields',
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
                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js';
                pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
                    pdfDoc = pdfDoc_;
                    pdfDoc.getPage(1).then(function (page) {
                        var viewport = page.getViewport({ scale: 1 });
                        var canvas = $("#pdfCanvas")[0];
                        var context = canvas.getContext("2d");
                        canvas.height = viewport.height;
                        canvas.width = viewport.width;

                        var renderContext = {
                            canvasContext: context,
                            viewport: viewport
                        };

                        page.render(renderContext).promise.then(function () {
                            renderSavedFields(savedFields);
                            readonly();
                        }).catch(function (error) {
                            console.error('Error during PDF rendering:', error);
                        });
                    }).catch(function (error) {
                        console.error('Error getting page:', error);
                    });
                }).catch(function (error) {
                    console.error('Error getting document:', error);
                });
            }
        });

        //function updateFieldsToDatabase() {
        //    var pdfUrl = $("#pdfUrl").val();
        //    var savedFields = [];
        //    var guid = $("#TemplateID").val();
        //    var sid = $("#ProcessID").val();

        //    $(".editable-input").each(function () {
        //        var input = $(this);
        //        var id = input.attr('data-id');
        //        var value = input.val();
        //        savedFields.push({ ID: id, Value: value, guid: guid, SID: sid });
        //    });

        //    $.ajax({
        //        url: 'ViewPdf.aspx/UpdateFields',
        //        type: 'POST',
        //        contentType: 'application/json; charset=utf-8',
        //        dataType: 'json',
        //        data: JSON.stringify({ fields: savedFields, pdfUrl: pdfUrl }),
        //        success: function (response) {
        //            alert('Fields saved successfully.');
        //        },
        //        error: function (xhr, status, error) {
        //            alert('Error saving fields: ' + error);
        //        }
        //    });
        //}

        function readonly() {
            const readonlyFields = document.getElementsByClassName("ReadonlyMode");

            for (let i = 0; i < readonlyFields.length; i++) {
                readonlyFields[i].readOnly = true;
            }
        }

        //async function downloadPdfWithFields() {
        //    const { PDFDocument, rgb } = PDFLib;
        //    const pdfUrl = $("#pdfUrl").val();

        //    const existingPdfBytes = await fetch(pdfUrl).then(res => res.arrayBuffer());
        //    const pdfDoc = await PDFDocument.load(existingPdfBytes);

        //    const pages = pdfDoc.getPages();
        //    const firstPage = pages[0];

        //    const { width, height } = firstPage.getSize();

        //    $(".editable-input").each(function () {
        //        const input = $(this);
        //        const id = input.attr('data-id');
        //        const value = input.val();
        //        const left = parseFloat(input.css('left'));
        //        const top = parseFloat(input.css('top'));

        //        firstPage.drawText(value, {
        //            x: left,
        //            y: height - top - 12, // Adjust for height offset and text size
        //            size: 12,
        //            color: rgb(0, 0, 0)
        //        });
        //    });

        //    const pdfBytes = await pdfDoc.save();
        //    const blob = new Blob([pdfBytes], { type: 'application/pdf' });
        //    const link = document.createElement('a');
        //    link.href = window.URL.createObjectURL(blob);
        //    link.download = 'signedPdf.pdf';
        //    link.click();
             
        //}
        function updateFieldsToDatabase( ) {
             
            var pdfUrl = $("#pdfUrl").val();
            var savedFields = [];
            var guid = $("#TemplateID").val();
            var sid = $("#ProcessID").val();

            $(".editable-input").each(function () {
                var input = $(this);
                var id = input.attr('data-id');
                var type = input.hasClass("name") ? "name" : input.hasClass("email") ? "email" : input.hasClass("signature") ? "signature" : "custom";
                var value = input.val();
                console.log(type)
                // Check if input has the ReadonlyMode class
                var isReadonly = input.hasClass("ReadonlyMode");
                 
                if (!isReadonly) {
                    if (type == "custom") {
                        console.log("enter")
                        // Find the signature image
                        var signatureImg = input.find('.signature-image'); // Assuming .signature-image is a class directly under .draggable-input

                        if (signatureImg.length > 0) {
                            var canvas = document.createElement('canvas');
                            canvas.width = signatureImg[0].width;
                            canvas.height = signatureImg[0].height;
                            var ctx = canvas.getContext('2d');
                            ctx.drawImage(signatureImg[0], 0, 0, signatureImg[0].width, signatureImg[0].height);
                            value = canvas.toDataURL(); // Get the dataURL of the signature image
                        }
                    }

                    // Push to savedFields only if not ReadonlyMode
                    savedFields.push({ ID: id, Value: value, guid: guid, SID: sid });
                }
            });


            $.ajax({
                url: 'ViewPdf.aspx/UpdateFields',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ fields: savedFields, pdfUrl: pdfUrl }),
                success: function (response) {
                    alert('Fields saved successfully.');
                    downloadPdfWithFields();
                },
                error: function (xhr, status, error) {
                    alert('Error saving fields: ' + error);
                }
            });
        }

        //async function downloadPdfWithFields(event) {
        //    event.preventDefault(); // Prevent form submission

        //    const { PDFDocument, rgb } = PDFLib;
        //    const pdfUrl = $("#pdfUrl").val(); // URL to the PDF file

        //    console.log("Fetching PDF from URL: ", pdfUrl);

        //    try {
        //        const response = await fetch(pdfUrl);
        //        const pdfBytes = await response.arrayBuffer();

        //        console.log('PDF fetched successfully');
        //        const pdfDoc = await PDFDocument.load(pdfBytes);

        //        const pages = pdfDoc.getPages();
        //        const firstPage = pages[0];
        //        const { width, height } = firstPage.getSize();

        //        $(".editable-input").each(function () {
        //            const input = $(this);
        //            const value = input.val();
        //            const left = parseFloat(input.css('left'));
        //            const top = parseFloat(input.css('top'));

        //            firstPage.drawText(value, {
        //                x: left,
        //                y: height - top - 12,
        //                size: 12,
        //                color: rgb(0, 0, 0)
        //            });
        //        });

        //        const updatedPdfBytes = await pdfDoc.save();
        //        const blob = new Blob([updatedPdfBytes], { type: 'application/pdf' });
        //        const link = document.createElement('a');
        //        link.href = URL.createObjectURL(blob);
        //        link.download = 'signedPdf.pdf';
        //        link.click();

        //        // If you need to save the PDF to the server
        //        await savePdfToServer(updatedPdfBytes);

        //    } catch (error) {
        //        console.error('Error:', error);
        //        alert('Error processing PDF: ' + error.message);
        //    }
        //}

        function downloadPdfWithFields(event) {
            event.preventDefault(); // Prevent form submission
            updateFieldsToDatabase();
            const { PDFDocument, rgb } = PDFLib;
            const pdfUrl = $("#pdfUrl").val(); // URL to the PDF file

            console.log("Fetching PDF from URL: ", pdfUrl);

            fetch(pdfUrl)
                .then(response => response.arrayBuffer())
                .then(pdfBytes => {
                    console.log('PDF fetched successfully');
                    return PDFDocument.load(pdfBytes);
                })
                .then(pdfDoc => {
                    const pages = pdfDoc.getPages();
                    const firstPage = pages[0];
                    const { width, height } = firstPage.getSize();

                    $(".editable-input").each(function () {
                        const input = $(this);
                        const value = input.val();
                        const left = parseFloat(input.css('left'));
                        const top = parseFloat(input.css('top'));

                        firstPage.drawText(value, {
                            x: left,
                            y: height - top - 12,
                            size: 12,
                            color: rgb(0, 0, 0)
                        });
                    });

                    return pdfDoc.save();
                })
                .then(updatedPdfBytes => {
                    const formData = new FormData();
                    const blob = new Blob([updatedPdfBytes], { type: 'application/pdf' });
                    formData.append('pdfFile', blob);

                    return savePdfToServer(formData);
                })
                .then(response => {
                    console.log('Response from server:', response.d);
                    alert('PDF saved successfully to SignedFiles folder.');
                })
                .catch(error => {
                    console.error('Error:', error);
                    console.log('Error processing PDF: ' + error.message);
                });
        }

        function savePdfToServer(formData) {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'POST',
                    url: 'SavePdfToServer.aspx', // ASPX page URL and method
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        resolve(response);
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
                activeSignatureBox.appendChild(img); // Append the scaled image
                img.className = 'signature-image';
                $('#signature-pad').modal('hide');
                clearCanvas(); // Clear the canvas after saving
            };
            img.src = signatureImg; // Set the image source to trigger onload event
        }

             
    });
    </script>
</asp:Content>
