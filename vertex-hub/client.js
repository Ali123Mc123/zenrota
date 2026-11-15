const resourceName = GetCurrentResourceName();

emitNet('requestVertexHubResources/ec2cfb3f-f389-47ef-8c70-4cc976c5be3c');

onNet('registerVertexHubResources/ec2cfb3f-f389-47ef-8c70-4cc976c5be3c', (resourcesDto) => {
	const resources = JSON.parse(resourcesDto);
	for (const { fileName, cacheString } of resources) {
		RegisterStreamingFileFromCache(resourceName, fileName, cacheString);
	}
});
