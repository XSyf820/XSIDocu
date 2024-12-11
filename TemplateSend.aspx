<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="TemplateSend.aspx.cs" Inherits="SigningFormGenerator.TemplateSend" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .draggable-input-wrapper {
            position: absolute;
            background-color: #fff;
            border: 2px dashed #FF2C2C;
            /*padding: 2px;*/
            cursor: move;
           
        }
    </style>

    <!-- Signature Pad Modal -->
    <div class="modal fade" id="signature-pad" tabindex="-1" role="dialog" aria-labelledby="signature-pad-label" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg " role="document">
            <div class="modal-content ">
                <div class="modal-header">
                    <h5 class="modal-title" id="signature-pad-label">Sign Here</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="card modal-body" style="margin-left:15px;margin-right:15px;">
                    <canvas id="canvas"></canvas>
                </div>
                <div class="card" style="margin-left:15px;margin-right:15px;">
                   <div class="form-check">
                      <input class="form-check-input checkbox-lg" type="checkbox"  id="userConcentCheck" >
                      <label class="form-check-label" for="flexCheckChecked">
                        I Accept
                             </label>
                    </div>
                    <div class="card" style="font-size:12px;">
                        The parties agree that the electronic signatures appearing on this agreement are the same as handwritten signatures for the purposes of validity, enforceability, and admissibility.
                   
                    </div>
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
        <h2> <span id="TemplateName" runat="server"></span> </h2>
        <asp:HiddenField ID="TemplateID" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="pdfUrl" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="TSID" runat="server" ClientIDMode="Static" />
         <label>Document Name</label>
        <input type="text" id="DocName" class="form-control" runat="server" ClientIDMode="Static" />

        <%-- <asp:FileUpload ID="FileUpload12" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Upload" OnClick="UploadButton_Click" CssClass="btn btn-primary mt-2" />--%>
        <hr />
        <div id="pdf-container" class="border" >
            <!-- PDF rendering -->
            <canvas id="pdfCanvas"></canvas>
            <div id="fieldOverlay"></div>
            <!-- created fields -->
        </div>
        <div id="field-tools" class="mt-3">
            <%--  <button type="button" class="btn btn-secondary" id="addNameField">Add Name Field</button>
            <button type="button" class="btn btn-secondary" id="addEmailField">Add Email Field</button>
            <button type="button" class="btn btn-secondary" id="addSignatureField">Add Signature Field</button>
            <button type="button" class="btn btn-danger" id="clearFields">Clear Fields</button>--%>
            <button type="button" class="btn btn-primary" id="saveFields">Next</button>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">

    <script>
        var activeSignatureBox = null;
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
            var savedFields = [];
            var pdfDoc = null;
            var pdfContainer = $("#pdf-container");
            var fieldOverlay = $("#fieldOverlay")[0]; // Get the DOM element

            var fieldCounters = {
                TextBox: 0,                 
                signature: 0
            };

           

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
                        page.render({ canvasContext: context, viewport: viewport });
                    });
                });
            }

            var pdfUrl = '<%= Session["UploadedPdfUrl"] %>';
            $("#pdfUrl").val(pdfUrl)
                if (pdfUrl) {
                    // renderPDF(pdfUrl);
                    // Check the session value and assign an empty string if it is null
                     
                    
                    
                        getSavedField();
                    var sid = $("#TSID").val();
                    if (sid != "" && sid != null) {

                        var tid = $("#TemplateID").val();
                        backtoPageMode(tid, sid);

                    }
                   
            }
            function backtoPageMode(TID, SID) {
                var processid = SID;
                var TID = TID;
                console.log(TID,SID)
                $.ajax({
                    url: 'TemplateSend.aspx/SentTemplateByID',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    data: JSON.stringify({ TID: TID, SID: processid }),
                    success: function (response) {
                        savedFields = response.d;
                        console.log("s", savedFields)
                        if (savedFields.length > 0) {
                            $.each(savedFields, function (index, s) {
                                var element = $('.pdfPage').find('#' + s.ID);

                                if (element.length > 0) {
                                    console.log("element found");
                                    if (s.FieldType == "signature") {
                                        if (s.Value != "" && s.Value != null) {
                                            var img = $('<img>').attr('src', s.Value.replace(/^~\//, '')).addClass('signature-image');
                                            element.empty();
                                            element.append(img);
                                        }
                                      
                                    } else {
                                        element.val(s.Value);
                                    }
                                }
                                   
                            });
                            
                        }
                        
                    },
                    error: function (xhr, status, error) {
                        alert('Error retrieving saved fields: ' + error);
                    }
                });
            }
                function getSavedField() {

                    var pdfUrl = $("#pdfUrl").val();

                    var TID = $("#TemplateID").val();
                    console.log(TID)
                    if (TID != null || TID != "") {
                        $.ajax({
                            url: 'TemplateCreate.aspx/GetSavedFields',
                            type: 'POST',
                            contentType: 'application/json; charset=utf-8',
                            dataType: 'json',
                            data: JSON.stringify({ TID: TID }),
                            success: function (response) {
                                savedFields = response.d;
                                console.log(savedFields)
                                renderSavedPDF(pdfUrl);
                            },
                            error: function (xhr, status, error) {
                                alert('Error retrieving saved fields: ' + error);
                            }
                        });
                    }  

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
                    signatureBox.addEventListener("click", function () {
                        activeSignatureBox = signatureBox;
                        $('#signature-pad').modal('show');
                    });
                    wrapper.appendChild(signatureBox);

                } else {
                    var input = document.createElement("input");
                    input.type = "text";
                    input.id = fieldId;
                    input.className = "draggable-input";
                    input.placeholder = type;
                    wrapper.appendChild(input);
                }

                wrapper.setAttribute("draggable", "false");

                var pageOverlay = $(".fieldOverlay[data-page-number='" + pageNumber + "']");
                pageOverlay.append(wrapper);

                 
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

             

            function renderSavedFields(savedFields) {
                $.each(savedFields, function (index, field) {
                    createDraggableInput(field.FieldType, field.LeftPosition, field.TopPosition, field.PageNumber, true);
                });
            }

                $("#saveFields").click(function () {
                    saveFieldsToDatabase();
                });

                $("#clearFields").click(function () {
                    $(".draggable-input-wrapper").remove();
                });

                function saveFieldsToDatabase() {
                    var pdfUrl = $("#pdfUrl").val();
                    var DocName = $("#DocName").val();

                    //var tempName = $("#TemplateName").innerText();
                    var TID = $("#TemplateID").val();
                      savedFields = [];
                    $(".draggable-input-wrapper").each(function () {
                        var input = $(this);
                        var type = input.hasClass("TextBox") ? "TextBox" : input.hasClass("signature") ? "signature" : "custom";
                        var left = parseInt(input.parent().css("left"));
                        var top = parseInt(input.parent().css("top"));
                        var value = input.find("input").val();
                       
                        if (type == "signature") {
                            // Find the signature image
                            var signatureImg = input.find('.signature-image'); 

                            if (signatureImg.length > 0) {
                                var canvas = document.createElement('canvas');
                                canvas.width = signatureImg[0].width;
                                canvas.height = signatureImg[0].height;
                                var ctx = canvas.getContext('2d');
                                ctx.drawImage(signatureImg[0], 0, 0, signatureImg[0].width, signatureImg[0].height);
                                value = canvas.toDataURL(); // Get the dataURL of the signature image

                            }
                        }
                        var fieldId = input.find("input").attr('id');
                        if (type == "signature") {
                            fieldId = input.find(".signature-box").attr('id');
                        }
                        savedFields.push({ ID: fieldId, FieldType: type, LeftPosition: left, TopPosition: top, Value: value });
                    });

                    $.ajax({
                        url: 'TemplateSend.aspx/SaveFields',
                        type: 'POST',
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        data: JSON.stringify({ fields: savedFields, pdfUrl: pdfUrl, TID: TID, DocName: DocName }),
                        success: function (response) {
                           // alert('Fields saved successfully.');
                            window.location.href = "Upload2.aspx";
                        },
                        error: function (xhr, status, error) {
                            console.error(xhr.responseText);
                        }
                    });
                }

                

               
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
                img.className = 'signature-image'; // Replace 'signature-image' with your desired class name

                activeSignatureBox.appendChild(img); // Append the scaled image
                $('#signature-pad').modal('hide');
                clearCanvas(); // Clear the canvas after saving
            };
            img.src = signatureImg; // Set the image source to trigger onload event
        }


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


    
     
    </script>



</asp:Content>
