-- Configuration
function love.conf(t)
	t.title = "Scrolling Shooter Tutorial" --title window string
	t.version = "0.10.2" --love version this game was made for
	t.window.width = 480
	t.window.height = 700
	
	-- Windows debugging (for Linux or Mac, run program through terminal; set to true for Windows)
	t.console = false
end
