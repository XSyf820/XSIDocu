<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/sign.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="SigningFormGenerator.Dashboard" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
  <div class="flex-1 flex-col relative z-0 overflow-y-auto">
			<div class="px-4 md:px-8 py-2 h-16 flex justify-between items-center shadow-sm bg-white">
				<div class="flex items-center w-2/3">
					<input class="bg-gray-200 focus:outline-none focus:shadow-outline focus:bg-white border border-transparent focus:border-gray-300 rounded-lg py-2 px-4 block w-full appearance-none leading-normal hidden md:block placeholder-gray-700 mr-10" type="text" placeholder="Buscar...">

					<div class="p-2 rounded-full hover:bg-gray-200 cursor-pointer md:hidden" @click="sidemenu = !sidemenu">
						<svg class="text-gray-600 hover:text-blue-600" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
							<rect x="0" y="0" width="24" height="24" stroke="none"></rect>
							<line x1="4" y1="6" x2="20" y2="6" />
							<line x1="4" y1="12" x2="20" y2="12" />
							<line x1="4" y1="18" x2="20" y2="18" />
						</svg>
					</div>
					<div class="text-xl font-bold tracking-tight text-gray-800 md:hidden ml-2">Dashboard</div>
				</div>
				<div class="flex items-center">

					<a class="relative p-2 text-gray-500 hover:bg-gray-200 hover:text-blue-600 mr-4 rounded-full cursor-pointer	">
						<span class="sr-only">Notificaciones</span>
						<span class="absolute top-0 right-0 h-2 w-2 mt-1 mr-2 bg-red-500 rounded-full"></span>
						<span class="absolute top-0 right-0 h-2 w-2 mt-1 mr-2 bg-red-500 rounded-full animate-ping"></span>
						<svg aria-hidden="true" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="h-6 w-6">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
						</svg>
					</a>

					<div class="relative" x-data="{ open: false }" x-cloak>
						<div @click="open = !open" class="cursor-pointer font-bold w-10 h-10 bg-blue-200 text-blue-400 hover:bg-blue-300 hover:text-blue-500 flex items-center justify-center rounded-full focus:ring-blue-500">
							IA
						</div>

						<div x-show.transition="open" @click.away="open = false" class="absolute top-0 mt-12 right-0 w-48 bg-white py-2 shadow-md border border-gray-100 rounded-lg z-40">
							<a href="#" class="block px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-blue-600">Editar perfil</a>
							<a href="#" class="block px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-blue-600">Cuenta</a>
							<a href="#" class="block px-4 py-2 text-gray-600 hover:bg-gray-100 hover:text-blue-600">Salir</a>
						</div>
					</div>
				</div>
			</div>

			<div class="md:max-w-6xl md:mx-auto px-4 py-8">

				<div class="bg-red-200 text-red-700 px-6 py-4 rounded-lg relative mb-5" role="alert" x-data="{ open: true }" x-show.transition="open">
					<div class="mr-4">
						<strong class="font-bold">Alerta:</strong>
						<span class="block sm:inline">Presión fuera de lo normal en punto 3</span>
					</div>

					<span class="cursor-pointer absolute top-0 bottom-0 right-0 hover:bg-red-100 hover:text-red-600 w-10 h-10 rounded-full inline-flex items-center justify-center mt-2 mr-3" x-on:click="open = false">
						<svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
							<rect x="0" y="0" width="24" height="24" stroke="none"></rect>
							<line x1="18" y1="6" x2="6" y2="18" />
							<line x1="6" y1="6" x2="18" y2="18" />
						</svg>
					</span>
				</div>

				<div class="flex items-center justify-between mb-4">
					<h2 class="text-xl text-gray-800">Bienvenido, <span class="font-bold">iaGlobal</span></h2>
					<div class="sm:col-span-3">
						<div class="mt-2">
							<select id="country" name="country" autocomplete="country-name" class="block w-full rounded-md border-0 py-2 px-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6">
								<option value="" disabled selected>Punto captación</option>
								<option>Punto 1</option>
								<option>Punto 2</option>
								<option>Punto 3</option>
							</select>
						</div>
					</div>

				</div>

				<section class="grid md:grid-cols-2 xl:grid-cols-5 xl:grid-flow-col gap-4">
					<div class="flex items-center p-3 bg-white shadow rounded-lg">
						<div class="inline-flex flex-shrink-0 items-center justify-center h-16 w-16 text-blue-600 bg-blue-100 rounded-full mr-6">
							<svg aria-hidden="true" fill="none" viewBox="0 0 20 20" stroke="currentColor" class="h-8 w-8">
								<path d="M14 14c1.448-1.448 2.5-3.29 2.5-5.5a8 8 0 1 0-16 0c0 2.21 1.052 4.052 2.5 5.5m5.5-5.5-4-4" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" /><circle cx="8.5" cy="8.5" fill="currentColor" r="1.5" />
							</svg>
						</div>
						<div>
							<span class="block text-xl font-bold">6 bar</span>
							<span class="block text-gray-500">Presión</span>
						</div>
					</div>
					<div class="flex items-center p-3 bg-white shadow rounded-lg">
						<div class="inline-flex flex-shrink-0 items-center justify-center h-16 w-16 text-green-600 bg-green-100 rounded-full mr-6">
							<svg aria-hidden="true" fill="false" viewBox="0 0 24 24" stroke="currentColor" class="h-6 w-6">
							<path d="M2.72 7.65a2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92 4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 1 0-.56 1.92Zm18 8.08a4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 1 0-.56 1.92 2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92Zm0-5a4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 0 0-1.32.68 1 1 0 0 0 .68 1.24 2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92Z"/>
							</svg>
						</div>
						<div>
							<span class="block text-xl font-bold">6.8 L/m</span>
							<span class="block text-gray-500">Caudal</span>
						</div>
					</div>
					<div class="flex items-center p-3 bg-white shadow rounded-lg">
						<div class="inline-flex flex-shrink-0 items-center justify-center h-16 w-16 text-yellow-600 bg-yellow-100 rounded-full mr-6">
							<svg aria-hidden="true" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="h-6 w-6">
							<path d="M2.72 7.65a2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92 4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 1 0-.56 1.92Zm18 8.08a4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 1 0-.56 1.92 2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92Zm0-5a4.5 4.5 0 0 0-1 .45 2.08 2.08 0 0 1-2.1 0 4.64 4.64 0 0 0-4.54 0 2.11 2.11 0 0 1-2.12 0 4.64 4.64 0 0 0-4.54 0 2.08 2.08 0 0 1-2.1 0 4.5 4.5 0 0 0-1-.45 1 1 0 0 0-1.32.68 1 1 0 0 0 .68 1.24 2.6 2.6 0 0 1 .56.24 4 4 0 0 0 4.1 0 2.6 2.6 0 0 1 2.56 0 4.15 4.15 0 0 0 4.12 0 2.6 2.6 0 0 1 2.56 0 4.25 4.25 0 0 0 2.08.56 3.9 3.9 0 0 0 2-.56 2.6 2.6 0 0 1 .56-.24 1 1 0 0 0-.56-1.92Z" />
							</svg>
						</div>
						<div>
							<span class="block text-xl font-bold">1200 m³</span>
							<span class="block text-gray-500">Acumulado</span>
						</div>
					</div>
					<div class="flex flex-col md:col-span-2 md:row-span-3 bg-white shadow rounded-lg">
						<div class="px-6 py-5 font-semibold border-b border-gray-100">Caudal y presión</div>
						<div class="p-4 flex-grow">
							<div class="flex items-center justify-center h-full px-4 py-16 text-gray-400 text-3xl font-semibold bg-gray-100 border-2 border-gray-200 border-dashed rounded-md"><canvas id="chart"></canvas>
							</div>
						</div>
					</div>
					<div class="flex flex-col md:col-span-2 md:row-span-3 bg-white shadow rounded-lg">
						<div class="px-6 py-5 font-semibold border-b border-gray-100">Mapa</div>
						<div class="p-4 flex-grow">
							<div class="flex items-center justify-center h-full text-gray-400 text-3xl font-semibold bg-gray-100 border-2 border-gray-200 border-dashed rounded-md">
								<div id="map" class="rounded-md overflow-hidden"></div>
							</div>
						</div>
					</div>
				</section>
				<div class="py-10 text-center">
					<p class="text-gray-600">Creado por <a class="text-blue-600 hover:text-blue-500 border-b-2 border-blue-200 hover:border-blue-300" href="#">Cristobal</a>. Con <a class="text-blue-600 hover:text-blue-500 border-b-2 border-blue-200 hover:border-blue-300" href="https://tailwindcss.com/">tailwindCSS</a> y <a href="https://github.com/alpinejs/alpine" class="text-blue-600 hover:text-blue-500 border-b-2 border-blue-200 hover:border-blue-300">AlpineJS</a>.</p>
				</div>
			</div>
		</div>
	<script>
        const osmLink = '<a href="http://openstreetmap.org">OpenStreetMap</a>';
        const osmUrl = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
        const osmAttrib = `&copy; ${osmLink} Contributors`;

        const osmMap = L.tileLayer(osmUrl, { attribution: osmAttrib });

        let config = {
            layers: [osmMap],
            minZoom: 7,
            maxZoom: 18,
            fullscreenControl: true,
        };

        const zoom = 10;
        const lat = -39.267;
        const lng = -71.967;

        const map = L.map("map", config).setView([lat, lng], zoom);

        setTimeout(function () {
            map.invalidateSize();
        }, 100);

        L.control
            .scale({
                imperial: false,
            })
            .addTo(map);

        L.marker([-39.267, -71.967]).addTo(map).bindPopup("Hola Pucon");

        const style = document.createElement("style");
        style.textContent = `.leaflet-tile-container { filter: grayscale(1)}`;
        document.head.appendChild(style);

        var chart = document.getElementById("chart").getContext("2d"),
            gradient = chart.createLinearGradient(0, 0, 0, 450);

        var data = {
            labels: [
                "Ene",
                "Feb",
                "Mar",
                "Abr",
                "May",
                "Jun",
                "Jul",
                "Ago",
                "Sep",
                "Oct",
                "Nov",
                "Dec"
            ],
            datasets: [
                {
                    label: "Flow",
                    data: [4.5, 4.5, 5, 6, 4, 5.5, 5.5, 6, 4.5, 4, 4, 5.5],
                    lineTension: 0,
                    fill: true,
                    borderColor: "#3b82f6",
                    backgroundColor: "transparent"
                },
                {
                    label: "Pressure",
                    lineTension: 0,
                    data: [60, 45, 80, 30, 35, 55, 25, 80, 40, 50, 80, 50],
                    fill: true,
                    borderColor: "#ef4444",
                    backgroundColor: "transparent"
                }
            ]
        };

        var options = {
            responsive: true,
            legend: {
                display: true,
                position: "top",
            }
        };

        var chartInstance = new Chart(chart, {
            type: "line",
            data: data,
            options: options
        });

        </script>
</asp:Content>
