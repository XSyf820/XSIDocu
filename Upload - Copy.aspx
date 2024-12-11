<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="SigningFormGenerator.Upload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        #pdf-container {
            position: relative;
        }

        #pdfCanvas {
            display: block;
        }

        #fieldOverlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: transparent;
            cursor: crosshair;
        }

        .draggable-input {
            position: absolute;
            background-color: #fff;
            border: 1px solid #ccc;
            padding: 5px;
            cursor: move;
        }

        /*.signature-box {
            border: 2px dashed #000;
            padding: 10px;
            cursor: move;
            text-align: center;
            font-size: 14px;
            font-weight: bold;
            position: relative;*/ /* Ensure position for image */
        /*}*/
         .signature-box {
        width: 200px;
        height: 60px;
        border: 2px solid #ccc;
        text-align: center;
        /*line-height: 100px;*/
        cursor: pointer;
        background-size: cover;
        background-position: center;
    }
        .draggable-input-wrapper {
            position: absolute;
            background-color: #fff;
            border: 1px solid #ccc;
            padding: 5px;
            cursor: move;
        }

        .delete-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            background-color: red;
            color: white;
            border: none;
            cursor: pointer;
            padding: 0 5px;
            z-index: 1;
        }
    </style>

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

    <div id="TemplateEdit">
        <h2>Create PDF Template</h2>
        <asp:FileUpload ID="FileUpload12" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Upload" OnClick="UploadButton_Click" CssClass="btn btn-primary mt-2" />
        <hr />
        <div id="pdf-container" class="border">
            <!-- PDF rendering -->
            <canvas id="pdfCanvas"></canvas>
            <div id="fieldOverlay"></div> <!-- created fields -->
        </div>
        <div id="field-tools" class="mt-3">
            <button type="button" class="btn btn-secondary" id="addNameField">Add Name Field</button>
            <button type="button" class="btn btn-secondary" id="addEmailField">Add Email Field</button>
            <button type="button" class="btn btn-secondary" id="addSignatureField">Add Signature Field</button>
            <button type="button" class="btn btn-danger" id="clearFields">Clear Fields</button>
            <button type="button" class="btn btn-primary" id="saveFields">Next</button>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">
   
        <script>
            $(document).ready(function () {
        var pdfDoc = null;
            var pdfContainer = $("#pdf-container");
            var fieldOverlay = $("#fieldOverlay")[0]; // Get the DOM element

            var fieldCounters = {
                name: 0,
            email: 0,
            signature: 0
        };

            var activeSignatureBox = null;

            function renderPDF(url) {
                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js';
            pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
                pdfDoc = pdfDoc_;
            pdfDoc.getPage(1).then(function (page) {
                    var viewport = page.getViewport({scale: 1 });
            var canvas = $("#pdfCanvas")[0];
            var context = canvas.getContext("2d");
            canvas.height = viewport.height;
            canvas.width = viewport.width;
            page.render({canvasContext: context, viewport: viewport });
                });
            });
        }

        var pdfUrl = '<%= Session["UploadedPdfUrl"] %>';
        if (pdfUrl) {
            renderPDF(pdfUrl);
        }

        function createDraggableInput(type, left, top) {
            var fieldId = type + '_' + (++fieldCounters[type]);

            // Create a wrapper div to hold the input and the delete button
            var wrapper = document.createElement("div");
            wrapper.className = "draggable-input-wrapper";
            wrapper.style.position = "absolute";
            wrapper.style.left = left + "px";
            wrapper.style.top = top + "px";

            if (type === "signature") {
                var signatureBox = document.createElement("div");
                signatureBox.className = "signature-box";
                signatureBox.id = fieldId;
                signatureBox.innerText = "Click here to sign";

                signatureBox.addEventListener("click", function () {
                    activeSignatureBox = signatureBox;
                    $('#signature-pad').modal('show');
                });

                wrapper.appendChild(signatureBox);
            } else {
                var input = document.createElement("input");
                input.type = "text";
                input.id = fieldId;
                input.className = "draggable-input " + type;
                input.placeholder = type;
                wrapper.appendChild(input);
            }

            var deleteBtn = document.createElement("button");
            deleteBtn.className = "delete-btn";
            deleteBtn.innerText = "X";
            deleteBtn.onclick = function () {
                fieldOverlay.removeChild(wrapper);
            };

            wrapper.appendChild(deleteBtn);
            wrapper.setAttribute("draggable", "true");
            fieldOverlay.appendChild(wrapper);

            wrapper.addEventListener("dragstart", function (event) {
                event.dataTransfer.setData("text/plain", null);
                wrapper.style.opacity = "0.5";
                event.dataTransfer.setDragImage(event.target, 0, 0);
            });

            wrapper.addEventListener("dragend", function (event) {
                var rect = pdfContainer[0].getBoundingClientRect();
                wrapper.style.left = (event.clientX - rect.left) + "px";
                wrapper.style.top = (event.clientY - rect.top) + "px";
                wrapper.style.opacity = "1";
            });
        }

        $("#addNameField").click(function () {
            createDraggableInput("name", 50, 50);
        });

        $("#addEmailField").click(function () {
            createDraggableInput("email", 100, 100);
        });

        $("#addSignatureField").click(function () {
            createDraggableInput("signature", 150, 150);
        });

        $("#saveFields").click(function () {
            saveFieldsToDatabase();
        });

        $("#clearFields").click(function () {
            $(".draggable-input-wrapper").remove();
        });

        function saveFieldsToDatabase() {
            var pdfUrl = '<%= Session["UploadedPdfUrl"] %>';
            var savedFields = [];
            $(".draggable-input").each(function () {
                var input = $(this);
            var type = input.hasClass("name") ? "name" : input.hasClass("email") ? "email" : input.hasClass("signature") ? "signature" : "custom";
            var left = parseInt(input.parent().css("left"));
            var top = parseInt(input.parent().css("top"));
            var value = input.val();
            savedFields.push({Id: input.attr('id'), FieldType: type, LeftPosition: left, TopPosition: top, Value: value });
            });
            $.ajax({
                url: 'Upload.aspx/SaveFields',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({fields: savedFields, pdfUrl: pdfUrl }),
            success: function (response) {
                alert('Fields saved successfully.');
            window.location.href = "Upload2.aspx";
                },
            error: function (xhr, status, error) {
                console.error(xhr.responseText);
                }
            });
        }

            var canvas = document.getElementById('canvas');
            var ctx = canvas.getContext('2d');
            ctx.strokeStyle = "#000";
            ctx.lineWidth = 2;
            var drawing = false;
            var mousePos = {x: 0, y: 0 };
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
                    $('#signature-pad').modal('hide');
                    clearCanvas(); // Clear the canvas after saving
                    };
                    img.src = signatureImg; // Set the image source to trigger onload event
        }
    });
        </script>

</asp:Content>
