<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="SignForm.aspx.cs" Inherits="SigningFormGenerator.SignForm" %>

<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="shortcut icon" type="image/png" href="Assets/images/cec.ico">
    <title>Sign PDF</title>


    <!-- Bootstrap CSS -->
    <link href="Assets/css/bootstrap.min.css?v=1.1" rel="stylesheet" />
    <!-- Theme Design -->
    <link href="Assets/css/all.css?v=1.1" rel="stylesheet" />
    <link href="Assets/css/style.css?ver=1.1" rel="stylesheet" />
    <link href="Assets/css/responsive.css?ver=1.1" rel="stylesheet" />
    <link href='https://unpkg.com/boxicons@2.0.7/css/boxicons.min.css?v=1.1' rel='stylesheet'>

    <!-- jQuery (required for Bootstrap's JS plugins) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- jQuery UI -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js?v=1.1"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
    <!-- Bootstrap JavaScript (required for modal) -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <!-- PDF.js and PDF-Lib -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js"></script>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <style>
        .sidebar .dropdown-menu {
            display: block;
            position: static;
            background-color: #265598;
            padding: 0px;
            border: 1px solid #265598;
        }

        .sidebar .dropdown-item {
            display: block;
            width: 100%;
            padding: 8px 15px;
            clear: both;
            font-weight: 400;
            color: #ffffff;
            text-align: inherit;
            text-decoration: none;
            white-space: nowrap;
            background-color: #265598;
            border: 0px solid #fff;
        }

            .sidebar .dropdown-item:hover {
                background-color: #1c4277;
            }

        .container {
            max-width: 1420px;
        }

        .dropdown-item.active {
            background-color: #1c4277;
            color: #fff;
        }


        #pdf-container {
            position: relative;
        }

        #pdfCanvas {
            display: block;
        }

        /*#fieldOverlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: transparent;*/ /*  overlay transparent */
        /*cursor: crosshair; 
    }*/

        /* .draggable-input {
        position: absolute;
        background-color: #fff;
        border: 1px solid #ccc;
        padding: 5px;
        cursor: move;
    }*/
        /*.signature-box {
        width: 200px;
        height: 60px;
        border: 2px solid #ccc;
        text-align: center;*/
        /*line-height: 100px;*/
        /*cursor: pointer;
        background-size: cover;
        background-position: center;
    }*/
        /*  .draggable-input-wrapper {
            position: absolute;
            background-color: #fff;
            border: 1px solid #ccc;
            padding: 5px;
            cursor: move;
        }*/

        /*  .delete-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            background-color: red;
            color: white;
            border: none;
            cursor: pointer;
            padding: 0 5px;
            z-index: 1;
        }*/
    </style>
    <style>
        #pdf-container {
            position: relative;
            max-height: 600px;  
            overflow-y: auto;
            overflow-x: hidden;
            border: 1px solid #ccc;
            padding: 10px;
        }

        #pdfCanvas {
            display: block;
            margin: 0 auto;
        }

        .pdfPage {
            position: relative;
            margin-bottom: 10px;
        }

        .fieldOverlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: transparent;
            cursor: crosshair;
        }

        .draggable-input-wrapper {
            position: absolute;
            /*background-color: #fff;*/
            /*border: 1px solid #ccc;*/
            /*padding: 2px;*/
            cursor: move;
            z-index: 2;
        }

        .signature-box {
            width: 200px;
            height: 60px;
            border: 2px solid #ccc;
            text-align: center;
            cursor: pointer;
            background-size: cover;
            background-position: center;
        }


        .ReadonlyMode {
            border: none;
        }

        .editable-input {
            border: 2px dashed #FF2C2C;
            /*padding: 10px;*/
            cursor: move;
            text-align: left;
            /*font-size: 14px;*/
            font-weight: bold;
            position: relative;
        }
    </style>
</head>
<body style="background-image: linear-gradient(180deg, rgb(255 255 255 / 14%) 0%, rgb(9 95 136 / 32%) 71%), url(Assets/images/home/bg.png);">


    <form runat="server">
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hf_IsShowQBOMsg" Value="" />
        <nav>
            <div class="navbar" id="navbar">

                <div class="logo d-flex flex-row">
                    <a class="navbar-brand d-flex align-items-center" href="Home.aspx">
                        <img src="Assets/images/logo/msScheduler-logo.png" class="img-responsive logo d-block" />
                    </a>
                    <a class="navbar-brand d-flex align-items-center d-md-block d-lg-none" href="#">
                        <img src="Assets/images/logo/cec.png" class="img-responsive ceclogo" />
                    </a>
                </div>
            </div>
        </nav>

        <div class="content d-flex flex-column flex-column-fluid">
            <div class="subheader py-4 py-lg-12 subheader-transparent">
                <div class="container d-flex align-items-center justify-content-between flex-wrap flex-sm-wrap flex-md-nowrap">
                    <!-- Info-->
                    <div class="w-100 d-block d-sm-block d-md-flex align-items-center flex-wrap mr-1 order-last order-sm-last order-md-first">
                        <div class="w-100 d-md-block d-lg-flex justify-content-start align-items-center">

                            <div>
                                <div class="col topper">
                                    <p class="text-start mb-0">
                                        <span class="companyname" id="TopComapnyName" runat="server" style="color: #fff;"></span>
                                        <br>
                                    </p>
                                </div>
                            </div>

                            <div class="px-3 d-none d-sm-none d-md-none d-lg-block">
                                <h1 class="text-white mb-0 opacity-75">|</h1>
                            </div>

                            <div class="py-2 d-block d-sm-block d-md-block d-lg-none">
                                <hr style="height: 2px; color: white;">
                            </div>

                            <div>
                                <div class="headcon d-flex">
                                    <div class="text pl-3 align-self-center">
                                        <h2 runat="server" id="h_PageName" class="pagetitle text-white font-weight-bold mb-0 opacity-75">Sign PDF</h2>
                                    </div>
                                    <a id="appcueToggle" href="javascript:Appcues.show('-LvfZuoFKg40RG0y7tVi')" style="display: block;">
                                        <div class="icon d-flex justify-content-center align-items-center"><i class="fas fa-question"></i></div>
                                    </a>
                                </div>
                            </div>



                        </div>
                    </div>

                    <div class="d-none d-sm-none d-md-flex align-items-center order-first order-sm-first order-md-last">
                        <div class="col-12 d-md-none d-lg-block">
                            <img src="Assets/images/logo/cec.png" class="img-responsive ceclogo">
                        </div>
                    </div>
                </div>
            </div>
        </div>






        <div class="d-flex flex-column-fluid home-1stsec">
            <div class="container">
                <div class="row">
                    <div class="col-12 mb-3">
                        <div class="card card-custom gutter-b card-stretch p-0" style="min-height: 600px">
                            <div class="card-body">


                                <div class="row" style="min-height: 600px">
                                    
                                    <center>
                                        <div class="col-12 col-sm-9 col-md-9">

                                            <!-- Signature Pad Modal -->
                                            <div class="modal fade" id="signature-pad" tabindex="-1" role="dialog" aria-labelledby="signature-pad-label" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title" id="signature-pad-label">Sign Here</h5>
                                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                <span aria-hidden="true">&times;</span>
                                                            </button>
                                                        </div>
                                                        <div class="card modal-body" style="margin-left: 15px; margin-right: 15px;">
                                                            <canvas id="canvas"></canvas>
                                                        </div>
                                                        <div class="card" style="margin-left: 15px; margin-right: 15px; text-align: left">
                                                            <div class="form-check">
                                                                <input class="form-check-input checkbox-lg" type="checkbox" id="userConcentCheck">
                                                                <label class="form-check-label" for="userConcentCheck">
                                                                    I Accept.
                                                                </label>
                                                            </div>
                                                            <p class="card" style="font-size: 12px;">
                                                                The parties agree that the electronic signatures appearing on this agreement are the same as handwritten signatures for the purposes of validity, enforceability, and admissibility.
                                                            </p>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                                            <button type="button" class="btn btn-primary" id="save-signature">Save</button>
                                                            <button type="button" class="btn btn-danger" id="clear-signature">Clear</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div id="TemplateEdit">
                                                <h2>Signed PDF Template</h2>
                                                <asp:HiddenField ID="ProcessID" runat="server" ClientIDMode="Static" />
                                                <asp:HiddenField ID="TemplateID" runat="server" ClientIDMode="Static" />
                                                <asp:HiddenField ID="pdfUrl" runat="server" ClientIDMode="Static" />
                                                <span id="TemplateName" runat="server"></span>
                                                 <hr />
                                                <div id="pdf-container" class="border">
                                                    <!-- PDF rendering -->
                                                    <canvas id="pdfCanvas"></canvas>
                                                    <div id="fieldOverlay"></div>
                                                    <!-- created fields -->
                                                </div>
                                                <div id="field-tools" class="mt-3">
                                                    <button id="downloadPdfBtn" class="btn btn-secondary" onclick="downloadPdfWithFields(event)">Submit PDF</button>

                                                </div>
                                            </div>







                                        </div>
                                    </center>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>




    <footer class="footer-sec">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <p style="text-align: center">
                        Copyright © 2024 All rights reserved by                        
                        <a href="https://www.xceleran.com/" target="_blank">xceleran.com</a>
                    </p>
                </div>
                <div class="col-12">
                    <p id="SessionValue" runat="server">
                    </p>
                </div>
            </div>
        </div>
    </footer>
    <script>
        // Initially disable the save button
        $('#save-signature').prop('disabled', true);


        $('#userConcentCheck').change(function () {
            if ($(this).is(':checked')) {
               
                $('#save-signature').prop('disabled', false);
            } else {
               
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

                    // Attach click event  
                    input.addEventListener("click", function () {
                        if (isEditable) {
                            activeSignatureBox = input;
                            $('#signature-pad').modal('show');
                        }
                    });

                    // If a signature value exists 
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
                            img.className = 'signature-image '  ;
                            input.innerHTML = '';  
                            input.appendChild(img);
                        };
                        img.src = value.replace('~/', '');
                        input.setAttribute('data-signature-url', value);
                    }

                    wrapper.appendChild(input);

                } else {
                     
                    input = document.createElement("input");
                    input.type = "text";
                    input.className = editable_className + " all-input " + readonly + " " + type;
                    input.placeholder = type;
                    input.value = value || "";
                    input.id = fieldId;
                    input.setAttribute("data-id", fieldId);

                    wrapper.appendChild(input);
                }

                 
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
                            pdfPage.setAttribute("data-page-number", page.pageNumber);  
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

                const pdfUrl = $("#pdfUrl").val();
                const response = await fetch(pdfUrl);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const pdfBytes = await response.arrayBuffer();
                const pdfDoc = await PDFDocument.load(pdfBytes);
                const pages = pdfDoc.getPages();

               
                await Promise.all($(".draggable-input-wrapper").map(async function () {
                    const $input = $(this);
                   
                    const leftPercentage = parseFloat($input.css('left')) / $input.closest(".fieldOverlay").width();
                    const topPercentage = parseFloat($input.css('top')) / $input.closest(".fieldOverlay").height();
                    const pageNum = $input.closest('.fieldOverlay').data('page-number') - 1;
                    console.log(leftPercentage, topPercentage, pageNum)
                    const page = pages[pageNum];
                    const { width, height } = page.getSize();

                    if ($input.hasClass("signature")) {
                        const signatureImg = $input.find('.signature-image');
                        if (signatureImg.length > 0) {
                            const src = signatureImg.attr('src');
                            if (src) {
                                try {
                                    const imgBlob = await fetch(src).then(res => res.blob());
                                    let pdfImage;

                                    
                                    if (src.endsWith('.png') || src.startsWith('data:image/png')) {
                                        pdfImage = await pdfDoc.embedPng(await imgBlob.arrayBuffer());
                                    } else if (src.endsWith('.jpg') || src.endsWith('.jpeg') || src.startsWith('data:image/jpeg')) {
                                        pdfImage = await pdfDoc.embedJpg(await imgBlob.arrayBuffer());
                                    } else {
                                        throw new Error('Unsupported image format');
                                    }

                                    const imgWidth = signatureImg.width();
                                    const imgHeight = signatureImg.height();

                                    page.drawImage(pdfImage, {
                                        x: leftPercentage * width,
                                        y: height - topPercentage * height - imgHeight,
                                        width: imgWidth,
                                        height: imgHeight,
                                    });
                                } catch (error) {
                                    console.error('Error embedding signature image:', error);
                                }
                            } else {
                                console.error('Signature image source is empty.');
                            }
                        }
                    } else {
                        const value = String($input.find("input").val());  
                        page.drawText(value, {
                            x: leftPercentage * width,
                            y: height - topPercentage * height - 12,
                            size: 12,
                            color: rgb(0, 0, 0)
                        });
                    }
                }).get()); 

                const updatedPdfBytes = await pdfDoc.save();
                const blob = new Blob([updatedPdfBytes], { type: 'application/pdf' });

                const formData = new FormData();
                formData.append('pdfFile', blob);

                await savePdfToServer(formData);
                alert('PDF saved successfully to SignedFiles folder.');
                window.location.href = "success.aspx"
            } catch (error) {
                console.error('Error in downloadPdfWithFields:', error);
                alert('Error processing PDF: ' + error.message);
            }
            window.location.href = "success.aspx"
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
                        //console.error('Error saving PDF:', error);
                        reject(error);
                    }
                });
            });


            //$.ajax({
            //    type: "POST",
            //    url: "SignForm.aspx/SavePdfToServer",
            //    data: formData,
            //    contentType: false,
            //    processData: false,
            //    success: function (response) {
            //        alert(response.d); // d contains the returned string from the WebMethod
            //        // Redirect to Success page if needed
            //    },
            //    error: function (xhr, status, error) {
            //        alert("Error: " + xhr.responseText);
            //    }
            //});
        }


        function loadImage(src) {
            return new Promise((resolve, reject) => {
                const img = new Image();
                img.onload = () => resolve(img);
                img.onerror = reject;
                img.src = src;
            });
        }

        async function getImageType(src) {
            const extension = src.split('.').pop().toLowerCase();
            if (extension === 'png') {
                return 'png';
            } else if (extension === 'jpg' || extension === 'jpeg') {
                return 'jpeg';
            } else {
                throw new Error('Unsupported image type');
            }
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
                    console.log(type)
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
                                console.log(value)
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
                console.log(savedFields)
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

                var signatureImg = canvas.toDataURL();  
                var img = new Image();
                img.onload = function () {
                    var maxWidth = $(activeSignatureBox).width();  
                    var maxHeight = $(activeSignatureBox).height();  
                    var widthRatio = maxWidth / img.width;
                    var heightRatio = maxHeight / img.height;
                    var scale = Math.min(widthRatio, heightRatio); 
                    img.width *= scale;  
                    img.height *= scale;  
                    $(activeSignatureBox).empty();  
                    img.className = 'signature-image';
                    activeSignatureBox.appendChild(img); 

                    $('#signature-pad').modal('hide');
                    clearCanvas();  
                };
                img.src = signatureImg;  
            }


        });
        function getImageType(src) {
            
            const extension = src.split('.').pop().toLowerCase();
            if (extension === 'png') {
                return extension;
            } else if (extension === 'jpg' || extension === 'jpeg') {
                return 'jpeg';  
            }
            return null; 
        }
    </script>

</body>
</html>
