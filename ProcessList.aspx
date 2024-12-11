<%@ Page Title="" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="ProcessList.aspx.cs" Inherits="SigningFormGenerator.ProcessList" %>
 
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

      <div class="col-12 mb-3">
        <div class="table-responsive">
            <table id="customerTable" class="table table-striped">
                <thead id="theadCustomers">
                    <tr>
                       
                        <%--<th >ID</th> --%>
                        <th>Template Name</th> 
                        <th>Doc Name</th> 

                        <th>Sender Email</th>
                        <th>Receiver Email</th>
                        <th>Send Date</th>
                        <th>Signed Date</th>
                        <th>View</th>

                    </tr>

                </thead>
                <tbody id="tbodyCustomers" runat="server">
                    <asp:PlaceHolder ID="ListTable" runat="server"></asp:PlaceHolder>
                </tbody>
            </table>
        </div>
                                  
    </div>
</asp:Content>
 
