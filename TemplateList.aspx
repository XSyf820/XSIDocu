<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="TemplateList.aspx.cs" Inherits="SigningFormGenerator.TemplateList" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex flex-column-fluid home-1stsec">
        <div class="container">
            <div class="row">
                <div class="col-12 mb-3">
                    <a href="TemplateCreate.aspx?n=1" class="btn btn-primary float-right">Add Template</a>
                    <br />
                    <div class="col-12 mb-3">
                        <!-- Start of alternative content -->
                        <div class="content-placeholder">
                            <p>Replace this section with your desired content or functionality.</p>
                            <!-- You can add forms, other lists, or dynamic content here -->
                        </div>
                        <!-- End of alternative content -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
