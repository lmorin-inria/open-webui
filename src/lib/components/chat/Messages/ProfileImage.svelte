<script lang="ts">
	import { settings } from '$lib/stores';
	import { WEBUI_BASE_URL } from '$lib/constants';
        import { WEBUI_BASE_PATH, WEBUI_DEFAULT_USER_ICON } from '$lib/constants';

	export let className = 'size-8';

	export let src = WEBUI_DEFAULT_USER_ICON;
</script>

<div class={`flex-shrink-0 ${($settings?.chatDirection ?? 'LTR') === 'LTR' ? 'mr-3' : 'ml-3'}`}>
	<img
		crossorigin="anonymous"
		src={src.startsWith(WEBUI_BASE_URL) ||
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
</div>
