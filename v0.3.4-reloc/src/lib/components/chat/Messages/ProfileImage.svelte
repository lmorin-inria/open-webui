<script lang="ts">
	import { settings } from '$lib/stores';
	import { WEBUI_BASE_URL, WEBUI_DEFAULT_USER_ICON } from '$lib/constants';

	export let src = WEBUI_DEFAULT_USER_ICON;
</script>

<div class={($settings?.chatDirection ?? 'LTR') === 'LTR' ? 'mr-3' : 'ml-3'}>
	<img
		crossorigin="anonymous"
		src={src.startsWith(WEBUI_BASE_URL) ||
		src.startsWith('https://www.gravatar.com/avatar/') ||
		src.startsWith('data:') ||
		src.startsWith('@a21e259c-1c80-4d6b-928f-89716d576c13@/')
			? src
			: `/user.png`}
		class=" w-8 object-cover rounded-full"
		alt="profile"
		draggable="false"
	/>
</div>
