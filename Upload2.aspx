<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="Upload2.aspx.cs" Inherits="SigningFormGenerator.Upload2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .editable-fields-container {
        background: linear-gradient(135deg, #007BFF, #00C6FF); /* Blue gradient background */
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2); /* Subtle shadow for depth */
        border: 1px solid #007BFF; /* Border matching the gradient */
        transition: transform 0.3s ease, box-shadow 0.3s ease; /* Smooth transition for hover effect */
    }

    .editable-fields-container:hover {
        transform: translateY(-5px); /* Lift on hover */
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3); /* Enhanced shadow on hover */
    }

    .editable-fields-container label {
        font-size: 1.5rem; /* Larger label font */
        color: #fff; /* White label text color */
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3); /* Subtle text shadow */
    }

    .custom-select-height {
        background-color: #fff; /* White background for the dropdown */
        border-radius: 5px; /* Rounded corners */
        padding: 12px; /* Increased padding inside the dropdown */
        font-size: 1.2rem; /* Larger font size for options */
        height: 60px !important; /* Increased height for the select box */
        display: flex; /* Ensure proper alignment */
        align-items: center; /* Center align text vertically */
    }

    .bootstrap-select .dropdown-toggle .filter-option-inner-inner {
        line-height: 3.5rem; /* Increase line height to match select height */
    }

    /* Increase the dropdown direction icon size */
    .bootstrap-select .dropdown-toggle .caret {
        font-size: 3.5rem; /* Increase the size of the dropdown icon */
        margin-top: 10px; /* Adjust the margin to align with the larger height */
    }

    #optFields:focus {
        border-color: #00C6FF; /* Border color change on focus */
        box-shadow: 0 0 5px rgba(0, 198, 255, 0.5); /* Glow effect on focus */
    }
</style>
   <%--    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.7.570/pdf.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.11.6/umd/popper.min.js"></script>

     <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.2/js/bootstrap.min.js"></script>--%>
    <%-- for multiple select start --%>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.13.1/css/bootstrap-select.css" />
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.13.1/js/bootstrap-select.min.js"></script>
       <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.11.6/umd/popper.min.js"></script>
    <%-- //for multiple select end --%>
     <div class="row mt-2">
    <div class="col-12 mt-0">
        <div class="editable-fields-container p-4 rounded">
            <label for="validationCustom01" class="form-label mb-2 font-weight-bold">
                <span style="color:red">*</span>Select Editable fields
            </label>
            <select id="optFields" runat="server" title="Select Editable Fields" 
                    style="width: 100%" 
                    class="form-control selectpicker custom-select-height" 
                    multiple="true" 
                    data-live-search="true" 
                    required>
            </select>
        </div>
    </div>
</div>
    <br/>
       <div id="SendMailBlock" >
         <asp:HiddenField ID="TID" runat="server" ClientIDMode="Static" />
        <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0"><span style="color:red">*</span>Email From :</label>

                <asp:TextBox ID="txt_EmailFrom" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>
            <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0"><span style="color:red">*</span>Email To :</label>

                <asp:TextBox ID="txt_EmailTO" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>

        <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0">Email CC :</label>

                <asp:TextBox ID="txt_EmailCC" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>
        <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0">Email BCC :</label>

                <asp:TextBox ID="txt_EmailBCC" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>

        <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0">Email Subject :</label>
                <asp:TextBox ID="txt_EmailSubject" Rows="2" TextMode="MultiLine" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>
        <div class="row mt-2">
            <div class="col-12 mt-0">
                <label for="validationCustom01" class="form-label mb-0">Email Body :</label>
                <asp:TextBox ID="txt_EmailBody" Rows="5" TextMode="MultiLine" runat="server" class="form-control"></asp:TextBox>

            </div>
        </div>
         <div class="row mt-2">
            <div class="col-12 mt-0">
                 <asp:LinkButton ToolTip="Send Email" CssClass="float-end btn btn-secondary m-2 followupButton" ID="lnkEdit"
                                runat="server" Text='Send Email.' OnClientClick="return validateInput()" OnClick="lnkEmail_Click1"><i class="fa fa-envelope"></i> Send Email.</asp:LinkButton>
             <asp:LinkButton ToolTip="Back" CssClass="float-start btn btn-secondary m-2 followupButton" ID="BackBtn"
                runat="server" Text='Back.' OnClientClick="return validateInput()" OnClick="lnkBack_CLick"><i class="fa fa-left-arrow"></i> Back.</asp:LinkButton>
            
                
            
            </div>
        </div>
        
    </div>

    <script>
        $('.selectpicker').selectpicker();
        
    </script>

</asp:Content>
