let moneyType = 'en-US';

function Notify(message, type) {
	if (type == 'success') {
		var randomId = Math.floor(Math.random() * 1000000);
		var notifyHTML = `
        <div id="${randomId}" class="d-plate d-note flex flex-col text-white p-4 gap-1" style="zoom:0.9;">
            <div class="flex gap-3 items-center text-xl font-semibold text-[#3BD67F]">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 0C5.37 0 0 5.37 0 12C0 18.63 5.37 24 12 24C18.63 24 24 18.63 24 12C24 5.37 18.63 0 12 0ZM11.0775 18.99H9.0675L4.2075 12.18L6.219 10.305L10.0725 13.905L17.784 5.0085L19.794 6.4185L11.0775 18.99Z" fill="#3BD67F"/>
                </svg>
                BAŞARILI
            </div>
            <div>${message}</div>
        </div>
        `;

		$('#notifys').append(notifyHTML);
		$(`#${randomId}`).hide();
		$(`#${randomId}`).fadeIn('slow');

		setTimeout(() => {
			$(`#${randomId}`).fadeOut('slow', function () {
				$(`#${randomId}`).remove();
			});
		}, 2500);
	} else {
		var randomId = Math.floor(Math.random() * 1000000);
		var notifyHTML = `
        <div id="${randomId}" class="d-plate d-note flex flex-col text-white p-4 gap-1" style="zoom:0.9;">
            <div class="flex gap-3 items-center text-xl font-semibold text-[#FF5A4F]">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 0C5.3832 0 0 5.3832 0 12C0 18.6168 5.3832 24 12 24C18.6168 24 24 18.6168 24 12C24 5.3832 18.6168 0 12 0ZM18 14.4H6V9.6H18V14.4Z" fill="#FF5A4F"/>
                </svg>
                HATA
            </div>
            <div>${message}</div>
        </div>
        `;

		$('#notifys').append(notifyHTML);
		$(`#${randomId}`).hide();
		$(`#${randomId}`).fadeIn('slow');

		setTimeout(() => {
			$(`#${randomId}`).fadeOut('slow', function () {
				$(`#${randomId}`).remove();
			});
		}, 2500);
	}
}

function renderInventoryUpgrade(data) {
	var inventoryStar = data.stationInfo.inventoryCapacityLevel;
	var fadeStar = 5 - inventoryStar;

	$('#inventoryStars').html(``);

	for (var i = 0; i < inventoryStar; i++) {
		$('#inventoryStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50"/>
        </svg>
        `);
	}

	for (var i = 0; i < fadeStar; i++) {
		$('#inventoryStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50" fill-opacity="0.5"/>
        </svg>
        `);
	}

	$('#inventoryCapacityInfos').html(``);

	for (var i = 0; i <= 6; i++) {
		if (i % 2 != 0 || i == 0) continue;
		var secondIsVisible = i > inventoryStar;
		var firstIsVisible = i - 1 > inventoryStar;

		var secondHtml;

		var firstHtml = `
            <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!firstIsVisible ? '' : 'opacity-50'}">Seviye ${i - 1}: + ${data.UpgradePrice['Inventory'][i - 1 + ''].value} birim</div>
        `;

		if (data.UpgradePrice['Inventory'][i + '']) {
			secondHtml = `
                <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!secondIsVisible ? '' : 'opacity-50'}">Seviye ${i}: + ${data.UpgradePrice['Inventory'][i + ''].value} birim</div>
            `;
		} else {
			secondHtml = `<div class="flex-1"></div>`;
		}

		$('#inventoryCapacityInfos').append(`
        <div class="flex flex-1 gap-2">
            ${firstHtml}
            ${secondHtml}
        </div>
        `);
	}

	if (inventoryStar == 5) {
		$('#upgradeInventoryPrice').text('Maksimum seviye');
	} else {
		$('#upgradeInventoryPrice').text('Yükseltme için $' + new Intl.NumberFormat(moneyType).format(data.UpgradePrice['Inventory'][Number(inventoryStar + 1) + '']?.price));
	}

	$('#upgradeInventoryBtn')
		.off('click')
		.on('click', function () {
			if (inventoryStar == 5) return;
			$.post(`https://${data.scriptName}/upgradeInventory`, JSON.stringify({}), function (response) {
				if (response) {
					Notify('Envanter başarıyla yükseltildi!', 'success');
				} else {
					Notify('Envanteri yükseltirken bir hata oluştu!', 'error');
				}
			});
		});
}

function validateWalletAmount(input) {
	if (input.value < 0) {
		input.value = 0;
	}
}

function renderTruckCapacityUpgrade(data) {
	var inventoryStar = data.stationInfo.truckCapacityLevel;
	var fadeStar = 5 - inventoryStar;

	$('#truckStars').html(``);

	for (var i = 0; i < inventoryStar; i++) {
		$('#truckStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50"/>
        </svg>
        `);
	}

	for (var i = 0; i < fadeStar; i++) {
		$('#truckStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50" fill-opacity="0.5"/>
        </svg>
        `);
	}

	$('#truckCapacityInfos').html(``);

	for (var i = 0; i <= 6; i++) {
		if (i % 2 != 0 || i == 0) continue;
		var secondIsVisible = i > inventoryStar;
		var firstIsVisible = i - 1 > inventoryStar;

		var secondHtml;

		var firstHtml = `
            <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!firstIsVisible ? '' : 'opacity-50'}">Seviye ${i - 1}: + ${data.UpgradePrice['TruckCapacity'][i - 1 + ''].value
			}% kapasite</div>
        `;

		if (data.UpgradePrice['Inventory'][i + '']) {
			secondHtml = `
                <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!secondIsVisible ? '' : 'opacity-50'}">Seviye ${i}: + ${data.UpgradePrice['TruckCapacity'][i + ''].value}% kapasite</div>
            `;
		} else {
			secondHtml = `<div class="flex-1"></div>`;
		}

		$('#truckCapacityInfos').append(`
        <div class="flex flex-1 gap-2">
            ${firstHtml}
            ${secondHtml}
        </div>
        `);
	}

	if (inventoryStar == 5) {
		$('#upgradeTruckPrice').text('Maksimum seviye');
	} else {
		$('#upgradeTruckPrice').text('Yükseltme için $' + new Intl.NumberFormat(moneyType).format(data.UpgradePrice['TruckCapacity'][Number(inventoryStar + 1) + '']?.price));
	}

	$('#upgradeTruckBtn')
		.off('click')
		.on('click', function () {
			if (inventoryStar == 5) return;
			$.post(`https://${data.scriptName}/upgradeTruckCapacity`, JSON.stringify({}), function (response) {
				if (response) {
					Notify('Kamyon kapasitesi başarıyla yükseltildi!', 'success');
				} else {
					Notify('Kamyon kapasitesi yükseltilirken bir hata oluştu!', 'error');
				}
			});
		});
}

function renderRelationshipUpgrade(data) {
	var inventoryStar = data.stationInfo.relationshipLevel;
	var fadeStar = 5 - inventoryStar;

	$('#RelationshipStars').html(``);

	for (var i = 0; i < inventoryStar; i++) {
		$('#RelationshipStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50"/>
        </svg>
        `);
	}

	for (var i = 0; i < fadeStar; i++) {
		$('#RelationshipStars').append(`
        <svg class="w-7 h-7" viewBox="0 0 40 38" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19.0489 0.927052C19.3483 0.00574112 20.6517 0.00573993 20.9511 0.927051L24.9393 13.2016C25.0732 13.6136 25.4571 13.8926 25.8904 13.8926H38.7966C39.7653 13.8926 40.1681 15.1322 39.3844 15.7016L28.943 23.2877C28.5925 23.5424 28.4459 23.9937 28.5798 24.4058L32.568 36.6803C32.8674 37.6017 31.8129 38.3678 31.0292 37.7984L20.5878 30.2123C20.2373 29.9576 19.7627 29.9576 19.4122 30.2123L8.97084 37.7984C8.18713 38.3678 7.13264 37.6017 7.432 36.6803L11.4202 24.4058C11.5541 23.9937 11.4075 23.5424 11.057 23.2877L0.6156 15.7016C-0.168114 15.1322 0.23466 13.8926 1.20338 13.8926H14.1096C14.5429 13.8926 14.9268 13.6136 15.0607 13.2016L19.0489 0.927052Z" fill="#E23A50" fill-opacity="0.5"/>
        </svg>
        `);
	}

	$('#relationShipInfo').html(``);

	for (var i = 0; i <= 6; i++) {
		if (i % 2 != 0 || i == 0) continue;
		var secondIsVisible = i > inventoryStar;
		var firstIsVisible = i - 1 > inventoryStar;

		var secondHtml;

		var firstHtml = `
            <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!firstIsVisible ? '' : 'opacity-50'}">Seviye ${i - 1}: + ${data.UpgradePrice['Relationship'][i - 1 + ''].value
			}% indirim</div>
        `;

		if (data.UpgradePrice['Relationship'][i + '']) {
			secondHtml = `
                <div class="flex-1 bg-white bg-opacity-[4%] text-center py-2 ${!secondIsVisible ? '' : 'opacity-50'}">Seviye ${i}: + ${data.UpgradePrice['Relationship'][i + ''].value}% indirim</div>
            `;
		} else {
			secondHtml = `<div class="flex-1"></div>`;
		}

		$('#relationShipInfo').append(`
        <div class="flex flex-1 gap-2">
            ${firstHtml}
            ${secondHtml}
        </div>
        `);
	}

	if (inventoryStar == 5) {
		$('#upgradeRelationPrice').text('Maksimum seviye');
	} else {
		$('#upgradeRelationPrice').text('Yükseltme için $' + new Intl.NumberFormat(moneyType).format(data.UpgradePrice['Relationship'][Number(inventoryStar + 1) + '']?.price));
	}

	$('#upgradeRelationBtn')
		.off('click')
		.on('click', function () {
			if (inventoryStar == 5) return;
			$.post(`https://${data.scriptName}/upgradeRelationship`, JSON.stringify({}), function (response) {
				if (response) {
					Notify('İlişki seviyesi başarıyla yükseltildi!', 'success');
				} else {
					Notify('İlişki seviyesi yükseltilirken bir hata oluştu!', 'error');
				}
			});
		});
}

$(document).ready(function () {
	window.addEventListener('message', function (event) {
		var data = event.data;
		switch (data.action) {
			case 'Notify':
				console.log(data.message, data.type);
				Notify(data.message, data.type);
				break;
			case 'openBuyStationMenu':
				$('.page').addClass('hidden');

				$('#buyStationMenu').removeClass('hidden');

				$('#gasStationBuyPrice').text('$ ' + new Intl.NumberFormat(moneyType).format(data.stationPrice));

				$('#buyGasStationBtn')
					.off('click')
					.on('click', function () {
						$.post(`https://${data.scriptName}/buyStation`, JSON.stringify({ stationId: data.stationId }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
							} else {
								Notify("Bu benzin istasyonunu satın almak için yeterli paranız yok!", 'error');
							}
						});
					});

				$('#closeBuyStation')
					.off('click')
					.on('click', function () {
						$('.page').addClass('hidden');
						$.post(`https://${data.scriptName}/close`, JSON.stringify({}));
					});

				break;
			case 'openFuelMenu':
				$('body').removeClass('hidden');
				$('.page').addClass('hidden');

				$('#buyFuelMenu').removeClass('hidden');

				$('#closeBuyFuelMenu')
					.off('click')
					.on('click', function () {
						$('.page').addClass('hidden');
						$.post(`https://${data.scriptName}/close`, JSON.stringify({}));
					});

				$('#stationStock').text(data.stationInfo.fuelStock);
				$('#stationFuelPrice').text(data.stationInfo.fuelPrice);

				$('#fuelInVehicle').text(data.fuelInVehicle.toFixed(0));
				$('#needToPay').text('0');
				$('#filledFuel').text('0');

				$('#priceToPay').val('');
				var canFillable = true;

				$('#startFilling')
					.off('click')
					.on('click', function () {
						if (!canFillable) return;
						canFillable = false;
						var priceToPay = $('#priceToPay').val();
						var fuelPrice = parseFloat(data.stationInfo.fuelPrice);

						var needToFill = 0;

						if (priceToPay == '' || priceToPay == 0) {
							var fuelInVehicle = parseFloat(data.fuelInVehicle).toFixed(0);

							var fillable = 100 - fuelInVehicle;

							needToFill = fillable;

							needToFill = needToFill.toFixed(0);

							console.log('Need to fill: ' + needToFill);
							console.log('Need to pay: ' + (needToFill * fuelPrice).toFixed(2));
						} else {
							var fuelInVehicle = parseFloat(data.fuelInVehicle).toFixed(0);

							var fillable = 100 - fuelInVehicle;

							needToFill = priceToPay / fuelPrice;

							if (needToFill > fillable) {
								needToFill = fillable;
							}

							needToFill = needToFill.toFixed(0);

							console.log('Need to fill: ' + needToFill);
							console.log('Need to pay: ' + (needToFill * fuelPrice).toFixed(2));
						}

						var needToPay = (needToFill * fuelPrice).toFixed(0);

						$.post(
							`https://${data.scriptName}/startFuel`,
							JSON.stringify({ fuelAmount: Number(needToFill), totalPrice: needToPay, vehicle: data.vehicle, pricePerLitre: data.stationInfo.fuelPrice }),
							function (response) {
								if (!response) {
									Notify('Yakıtı doldurmak için yeterli paranız yok!', 'error');
								}
							}
						);
					});

				var canStopable = true;

				$('#stopFilling')
					.off('click')
					.on('click', function () {
						console.log(canStopable, canFillable);
						if (!canStopable) return;
						canStopable = false;
						$.post(`https://${data.scriptName}/stopFuel`, JSON.stringify({}), function (response) {
							canStopable = true;
							canFillable = true;
						});
					});

				$('#payFuelBtn')
					.off('click')
					.on('click', function () {
						$.post(`https://${data.scriptName}/stopFuel`, JSON.stringify({}), function () { });
						$.post(`https://${data.scriptName}/payFuel`, JSON.stringify({ vehicle: data.vehicle }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
							}
						});
					});

				break;
			case 'updateFueling':
				$('#fuelInVehicle').text(data.fuel.toFixed(0));
				$('#needToPay').text(Number(data.totalFilled) * Number(data.fuelPrice));
				$('#filledFuel').text(data.totalFilled);
				break;
			case 'openJobListMenu':
				$('body').removeClass('hidden');
				$('.page').addClass('hidden');

				$('#joblistMenu').removeClass('hidden');

				$('#jobListExit')
					.off('click')
					.on('click', function () {
						$('.page').addClass('hidden');
						$.post(`https://${data.scriptName}/close`, JSON.stringify({}));
					});

				data.stationInfo.activeJobs = JSON.parse(data.stationInfo.activeJobs);

				$('#joblists').html(``);

				Object.keys(data.stationInfo.activeJobs).map((jobId) => {
					var job = data.stationInfo.activeJobs[jobId];

					$('#joblists').append(`
                    <div class="rounded-[3px] bg-white bg-opacity-[4%] py-2 px-4 flex justify-between items-center">
                        <div class="pl-3 line-clamp-1">${job.title}</div>
                        <div class="flex items-center gap-4">
                            <div class="flex flex-col w-24 justify-end gap-0.5 ">
                                <div class="text-right text-white text-xs font-light text-opacity-50">
                                    Ödül: $${new Intl.NumberFormat(moneyType).format(job.reward)}
                                </div>
                                <div class="text-right text-white text-xs font-light text-opacity-50">
                                    Miktar: ${job.fuel} L
                                </div>
                            </div>
                            <div data-jobid="${jobId}" class="getJob w-32 flex items-center justify-center bg-[#3BD67F] bg-opacity-10 hover:bg-opacity-20 transition-all px-6 py-2 text-[#3BD67F] rounded-[3px] cursor-pointer">
                                İşi Al
                            </div>
                        </div>
                    </div>
                    `);
				});

				$('.getJob')
					.off('click')
					.on('click', function () {
						var jobId = $(this).data('jobid');

						$.post(`https://${data.scriptName}/getJob`, JSON.stringify({ job: data.stationInfo.activeJobs[jobId], jobId: jobId }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
							} else {
								Notify('İşi alırken bir hata oluştu!', 'error');
							}
						});
					});

				break;
			case 'openManagementMenu':
				$('body').removeClass('hidden');
				$('.page').addClass('hidden');

				$('#adminMenu').removeClass('hidden');

				$('#adminMenuExit')
					.off('click')
					.on('click', function () {
						$('.page').addClass('hidden');
						$.post(`https://${data.scriptName}/close`, JSON.stringify({}));
					});

				var extraInventoryCapacity = data.UpgradePrice['Inventory'][data.stationInfo.inventoryCapacityLevel + '']?.value
					? data.UpgradePrice['Inventory'][data.stationInfo.inventoryCapacityLevel + ''].value
					: 0;
				var totalFuelCapacity = Number(data.DefaultCapacity) + Number(extraInventoryCapacity);
				var stockFuelPercent = (data.stationInfo.fuelStock / totalFuelCapacity) * 100;

				$('#maxInventoryCapacity').text(totalFuelCapacity);
				$('#fuelStockPercentStat').text(stockFuelPercent.toFixed(2) + '%');
				$('#fuelPercentFuel').text(stockFuelPercent.toFixed(0) + '%');
				$('#fuelBarStat').css('width', stockFuelPercent + '%');
				$('#fuelBarWave').css('height', stockFuelPercent + '%');

				$('#totalImport').text(data.stationInfo.totalImport + ' L');
				$('#totalDistance').text((data.stationInfo.totalDistance / 1000).toFixed(2) + ' KM');
				$('#visits').text(data.stationInfo.visits);
				$('#customers').text(data.stationInfo.customers);

				$('#totalMoneyWonStat').text('$ ' + new Intl.NumberFormat(moneyType).format(data.stationInfo.totalIncome));
				$('#totalMoneySpentStat').text('$ ' + new Intl.NumberFormat(moneyType).format(data.stationInfo.totalSpent));

				$('#setFuelPriceInput').val(parseFloat(data.stationInfo.fuelPrice).toFixed(2));

				$('#setFuelPriceBtn')
					.off('keydown')
					.on('keydown', function (e) {
						var maxValue = parseFloat(data.MaxGasPrice).toFixed(2);
						if (e.keyCode == 13) {
							var newPrice = parseFloat($('#setFuelPriceInput').val()).toFixed(2);

							if (parseInt(newPrice) > parseInt(maxValue)) {
								newPrice = maxValue;
								Notify('Fiyatı maksimum değerden yüksek ayarlayamazsınız!', 'error');
							}

							$('#setFuelPriceInput').val(newPrice.toFixed(2));

							$.post(`https://${data.scriptName}/setFuelPrice`, JSON.stringify({ price: newPrice }), function (response) {
								if (response) {
									Notify('Yeni fiyat başarıyla ayarlandı!', 'success');
								} else {
									Notify('Yeni fiyat ayarlanırken bir hata oluştu!', 'error');
								}
							});
						}
					});

				$('#setFuelPriceBtn')
					.off('click')
					.on('click', function () {
						var newPrice = parseFloat($('#setFuelPriceInput').val()).toFixed(2);
						var maxValue = parseFloat(data.MaxGasPrice).toFixed(2);

						if (parseInt(newPrice) > parseInt(maxValue)) {
							newPrice = maxValue;
							Notify('Fiyatı maksimum değerden yüksek ayarlayamazsınız!', 'error');
						}

						$('#setFuelPriceInput').val(newPrice);

						$.post(`https://${data.scriptName}/setFuelPrice`, JSON.stringify({ price: newPrice }), function (response) {
							if (response) {
								Notify('Yeni fiyat başarıyla ayarlandı!', 'success');
							} else {
								Notify('Yeni fiyat ayarlanırken bir hata oluştu!', 'error');
							}
						});
					});

				$('#smallCargoAmount').text(data.ReFuelPrices['small'].fuel);
				$('#mediumCargoAmount').text(data.ReFuelPrices['medium'].fuel);
				$('#largeCargoAmount').text(data.ReFuelPrices['large'].fuel);

				var discountPercent = data.UpgradePrice.Relationship[data.stationInfo.relationshipLevel + '']?.value
					? Number(data.UpgradePrice.Relationship[data.stationInfo.relationshipLevel + '']?.value)
					: 0;

				var capacityMultiplier = 1;
				if (data.stationInfo.truckCapacityLevel > 0) {
					var capValue = data.UpgradePrice.TruckCapacity[data.stationInfo.truckCapacityLevel + '']?.value;
					if (capValue) {
						capacityMultiplier = (Number(capValue) + 100) / 100;
					}
				}

				data.ReFuelPrices['small'].import = (data.ReFuelPrices['small'].import * capacityMultiplier) * (1 - discountPercent / 100);
				data.ReFuelPrices['medium'].import = (data.ReFuelPrices['medium'].import * capacityMultiplier) * (1 - discountPercent / 100);
				data.ReFuelPrices['large'].import = (data.ReFuelPrices['large'].import * capacityMultiplier) * (1 - discountPercent / 100);

				$('#smallCargoImport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['small'].import));
				$('#mediumCargoImport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['medium'].import));
				$('#largeCargoImport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['large'].import));

				$('#smallCargoExport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['small'].export * capacityMultiplier));
				$('#mediumCargoExport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['medium'].export * capacityMultiplier));
				$('#largeCargoExport').text(new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['large'].export * capacityMultiplier));

				$('.importFuelBtn')
					.off('click')
					.on('click', function () {
						var package = $(this).data('package');

						$.post(`https://${data.scriptName}/importFuel`, JSON.stringify({ package: package }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
							} else {
								Notify('Bu yakıt paketini veya stok kapasitesini ithal etmek için yeterli paranız yok!', 'error');
							}
						});
					});

				$('.exportFuelBtn')
					.off('click')
					.on('click', function () {
						var package = $(this).data('package');

						$.post(`https://${data.scriptName}/exportFuel`, JSON.stringify({ package: package }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
							} else {
								Notify('Dışa aktarmak için yeterli yakıtınız yok!', 'error');
							}
						});
					});

				$('#transferStationBtn')
					.off('click')
					.on('click', function () {
						var transferStationId = $('#transferStationId').val();

						if (transferStationId == '') {
							Notify('Yakıtı devretmek için bir istasyon ID\'si girmelisiniz!', 'error');
							return;
						}

						$.post(`https://${data.scriptName}/transferStation`, JSON.stringify({ playerId: Number(transferStationId) }), function (response) {
							if (response) {
								$('.page').addClass('hidden');
								Notify('Yakıt başarıyla transfer edildi!', 'success');
							} else {
								Notify('İstasyon devredilirken bir hata oluştu!', 'error');
							}
						});
					});

				$('#totalBalance').text('$ ' + new Intl.NumberFormat(moneyType).format(data.stationInfo.money));

				$('#withdrawBtn')
					.off('click')
					.on('click', function () {
						var value = $('#walletAmountInput').val();

						if (value == '' || value == 0) {
							Notify('Çekilecek miktarı girmeniz gerekiyor!', 'error');
							return;
						}

						$.post(`https://${data.scriptName}/withdraw`, JSON.stringify({ amount: value }), function (response) {
							if (response) {
								Notify('Para başarıyla çekildi!', 'success');
							} else {
								Notify('Parayı çekerken bir hata oluştu!', 'error');
							}
						});
					});

				$('#depositBtn')
					.off('click')
					.on('click', function () {
						var value = $('#walletAmountInput').val();

						if (value == '' || value == 0) {
							Notify('Yatırılacak miktarı girmeniz gerekiyor!', 'error');
							return;
						}

						$.post(`https://${data.scriptName}/deposit`, JSON.stringify({ amount: value }), function (response) {
							if (response) {
								Notify('Para başarıyla yatırıldı!', 'success');
							} else {
								Notify('Parayı yatırırken bir hata oluştu!', 'error');
							}
						});
					});

				$('#moneyHistory').html(``);

				var moneyHistory = JSON.parse(data.stationInfo.moneyHistory);

				moneyHistory.sort(function (a, b) {
					return new Date(b.date) - new Date(a.date);
				});

				moneyHistory = moneyHistory.slice(0, 20);

				moneyHistory.map((history) => {
					var date = new Date(history.date * 1000);
					var formattedDate = `${date.getDate()}.${date.getMonth() + 1}.${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}`;

					$('#moneyHistory').append(`
                    <div class="rounded-[3px] bg-white bg-opacity-[4%] py-3 px-4 flex justify-between items-center">
                        <div class="pl-3 uppercase">${history.title}</div>
                        <div class="flex flex-col justify-end gap-0.5">
                            <div class="text-right tracking-wider text-white text-xs font-light text-opacity-50">
                                Tutar: $${new Intl.NumberFormat(moneyType).format(history.value)}
                            </div>
                            <div class="text-right tracking-wider text-white text-xs font-light text-opacity-50">
                                ${formattedDate}
                            </div>
                        </div>
                    </div>`);
				});

				renderInventoryUpgrade(data);
				renderTruckCapacityUpgrade(data);
				renderRelationshipUpgrade(data);

				$('#optionSmall').text('KÜÇÜK ' + data.ReFuelPrices['small'].fuel + 'L ' + '$' + new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['small'].import));
				$('#optionMedium').text('ORTA ' + data.ReFuelPrices['medium'].fuel + 'L ' + '$' + new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['medium'].import));
				$('#optionLarge').text('BÜYÜK ' + data.ReFuelPrices['large'].fuel + 'L ' + '$' + new Intl.NumberFormat(moneyType).format(data.ReFuelPrices['large'].import));

				$('#createJobForm')
					.off('submit')
					.on('submit', function (e) {
						e.preventDefault();

						var jobTitle = $('#jobTitle').val();
						var jobReward = $('#jobReward').val();
						var jobPackage = $('#jobPackage').val();

						if (jobTitle == '' || jobReward == '' || jobPackage == '') {
							Notify('Bir iş oluşturmak için tüm alanları doldurmalısınız!', 'error');
							return;
						}

						$.post(`https://${data.scriptName}/createJob`, JSON.stringify({ title: jobTitle, reward: jobReward, package: jobPackage }), function (response) {
							if (response) {
								Notify('İş başarıyla oluşturuldu!', 'success');
							} else {
								Notify('Bu işi oluşturmak için yeterli paranız yok!', 'error');
							}
						});
					});

				$('#activeJobList').html(``);
				data.stationInfo.activeJobs = JSON.parse(data.stationInfo.activeJobs);
				// data.stationInfo.activeJobs key value
				Object.keys(data.stationInfo.activeJobs).map((jobId) => {
					var job = data.stationInfo.activeJobs[jobId];

					$('#activeJobList').append(`
                    <div class="rounded-[3px] bg-white bg-opacity-[4%] py-2 px-4 flex justify-between items-center">
                        <div class="text-lg pl-3">${job.title}</div>
                        <div class="flex items-center gap-4">
                            <div class="flex flex-col justify-end gap-0.5">
                                <div class="text-right text-white text-xs font-light text-opacity-50">
                                    Ödül: ${new Intl.NumberFormat(moneyType).format(job.reward)}$
                                </div>
                                <div class="text-right text-white text-xs font-light text-opacity-50">
                                    Miktar: ${job.fuel} L
                                </div>
                            </div>
                            <div data-jobid="${jobId}" class="cancelJobBtn bg-[#FF5A4F] bg-opacity-10 hover:bg-opacity-20 transition-all px-6 py-2 text-[#FF5A4F] rounded-[3px] cursor-pointer">
                                İptal Et
                            </div>
                        </div>
                    </div>
                    `);
				});

				$('.cancelJobBtn')
					.off('click')
					.on('click', function () {
						var jobId = $(this).data('jobid');

						$.post(`https://${data.scriptName}/cancelJob`, JSON.stringify({ jobId: jobId }), function (response) {
							if (response) {
								Notify('İş başarıyla iptal edildi!', 'success');
							} else {
								Notify('İşi iptal ederken bir hata oluştu!', 'error');
							}
						});
					});

				break;
			case 'updateBalance':
				$('#totalBalance').text('$ ' + new Intl.NumberFormat(moneyType).format(data.stationInfo.money));
				$('#moneyHistory').html(``);

				var moneyHistory = JSON.parse(data.stationInfo.moneyHistory);

				moneyHistory.sort(function (a, b) {
					return new Date(b.date) - new Date(a.date);
				});

				moneyHistory.map((history) => {
					var date = new Date(history.date * 1000);
					var formattedDate = `${date.getDate()}.${date.getMonth() + 1}.${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}`;

					$('#moneyHistory').append(`
                    <div class="rounded-[3px] bg-white bg-opacity-[4%] py-3 px-4 flex justify-between items-center">
                        <div class="pl-3 uppercase">${history.title}</div>
                        <div class="flex flex-col justify-end gap-0.5">
                            <div class="text-right tracking-wider text-white text-xs font-light text-opacity-50">
                                Tutar: $${new Intl.NumberFormat(moneyType).format(history.value)}
                            </div>
                            <div class="text-right tracking-wider text-white text-xs font-light text-opacity-50">
                                ${formattedDate}
                            </div>
                        </div>
                    </div>
                    `);
				});
				break;
			case 'close':
				$('.page').addClass('hidden');
				break;
		}
	});

	let selectedTab = 'statistic';

	let canClickAgain = true;

	$('.navItem').on('click', function () {
		if ($(this).data('tab') == selectedTab) return;
		if (!canClickAgain) return;

		$('.navItem').removeClass('bg-[#E23A50]');
		$('.navItem').removeClass('text-[#E23A50]');
		$('.navItem').removeClass('bg-opacity-[4%]');

		$('.navItem').addClass('bg-white');
		$('.navItem').addClass('text-white');
		$('.navItem').addClass('bg-opacity-[4%]');

		$(this).addClass('bg-[#E23A50]');
		$(this).addClass('text-[#E23A50]');
		$(this).addClass('bg-opacity-10');

		$(this).removeClass('bg-white');
		$(this).removeClass('text-white');
		$(this).removeClass('bg-opacity-[4%]');

		let newTab = $(this).data('tab');
		let oldTab = selectedTab;

		selectedTab = newTab;

		canClickAgain = false;

		$('.tab').fadeOut(150);
		setTimeout(function () {
			$('#' + newTab + 'Tab')
				.css('display', 'flex')
				.hide()
				.fadeIn(150, function () {
					canClickAgain = true;
				});
		}, 150);
	});
});
