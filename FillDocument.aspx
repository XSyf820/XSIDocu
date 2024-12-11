<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="FillDocument.aspx.cs" Inherits="SigningFormGenerator.FillDocument" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Fill Document</h2>
    <div id="pdf-container" class="border">
        <!-- PDF will be shown here -->
    </div>
    <asp:Button ID="SaveButton" runat="server" Text="Save" CssClass="btn btn-primary mt-3" OnClientClick="saveFields();" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ScriptContent" runat="server">
    <!-- Include PDF.js from a CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            var pdfDoc = null;
            var pdfContainer = $("#pdf-container");

            function renderPDF(url) {
                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.worker.min.js';
                pdfjsLib.getDocument(url).promise.then(function (pdfDoc_) {
                    pdfDoc = pdfDoc_;
                    pdfDoc.getPage(1).then(function (page) {
                        var viewport = page.getViewport({ scale: 1 });
                        var canvas = $("<canvas></canvas>");
                        var context = canvas[0].getContext("2d");
                        canvas[0].height = viewport.height;
                        canvas[0].width = viewport.width;
                        page.render({ canvasContext: context, viewport: viewport });
                        pdfContainer.html(canvas);
                    });
                });
            }

            function loadFields(fields) {
                fields.forEach(function (fieldData) {
                    var field = $("<div class='field'></div>").css({
                        left: fieldData.left,
                        top: fieldData.top,
                        width: fieldData.width,
                        height: fieldData.height
                    }).addClass(fieldData.type + "-field");

                    if (fieldData.type === "signature") {
                        field.html("Signature");
                    } else {
                        field.html("<input type='text' class='form-control' name='field_" + fieldData.type + "' />");
                    }

                    pdfContainer.append(field);
                });
            }

            // Render uploaded PDF and load fields
            var pdfUrl = '<%= Session["UploadedPdfUrl"] %>';
            if (pdfUrl) {
                renderPDF(pdfUrl);

                $.getJSON('Uploads/fields.json', function (fields) {
                    loadFields(fields);
                });
            }
        });

        function saveFields() {
            document.forms[0].submit();
        }
    </script>
</asp:Content>