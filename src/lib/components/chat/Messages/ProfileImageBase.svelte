<script lang="ts">
	import { WEBUI_BASE_URL } from '$lib/constants';
        import { WEBUI_BASE_PATH, WEBUI_DEFAULT_USER_ICON } from '$lib/constants';

	export let className = 'size-8';
	export let src = `${WEBUI_BASE_URL}/static/favicon.png`;
</script>

<img
	crossorigin="anonymous"
	src={src === ''
		? `${WEBUI_BASE_URL}/static/favicon.png`
		: src.startsWith(WEBUI_BASE_URL) ||
			  src.startsWith('https://www.gravatar.com/avatar/') ||
			  src.startsWith('data:') ||
			  src.startsWith('/') ||
			  src.startsWith(WEBUI_BASE_PATH)
			? src
			: WEBUI_DEFAULT_USER_ICON}
	class=" {className} object-cover rounded-full -translate-y-[1px]"
	alt="profile"
	draggable="false"
/>
