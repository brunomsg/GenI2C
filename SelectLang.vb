Module SelectLang

    Dim LangSelect As String

    Sub Main()
        Console.WriteLine()
        Console.WriteLine("         _              _            _              _        _                _      ")
        Console.WriteLine("        /\ \           /\ \         /\ \     _     /\ \    /\ \             /\ \     ")
        Console.WriteLine("       /  \ \         /  \ \       /  \ \   /\_\   \ \ \  /  \ \           /  \ \    ")
        Console.WriteLine("      / /\ \_\       / /\ \ \     / /\ \ \_/ / /   /\ \_\/ /\ \ \         / /\ \ \   ")
        Console.WriteLine("     / / /\/_/      / / /\ \_\   / / /\ \___/ /   / /\/_/\/_/\ \ \       / / /\ \ \  ")
        Console.WriteLine("    / / / ______   / /_/_ \/_/  / / /  \/____/   / / /       / / /      / / /  \ \_\ ")
        Console.WriteLine("   / / / /\_____\ / /____/\    / / /    / / /   / / /       / / /      / / /    \/_/ ")
        Console.WriteLine("  / / /  \/____ // /\____\/   / / /    / / /   / / /       / / /  _   / / /          ")
        Console.WriteLine(" / / /_____/ / // / /______  / / /    / / /___/ / /__     / / /_/\_\ / / /________   ")
        Console.WriteLine("/ / /______\/ // / /_______\/ / /    / / //\__\/_/___\   / /_____/ // / /_________\  ")
        Console.WriteLine("\/___________/ \/__________/\/_/     \/_/ \/_________/   \________/ \/____________/  ")
        'http://patorjk.com Impossible
        Console.WriteLine()

        While LangSelect <> "1" And LangSelect <> "2"
            Console.WriteLine()
            Console.WriteLine("Select Language 选择语言:")
            Console.WriteLine()
            Console.WriteLine("1) English")
            Console.WriteLine("2) 简体中文")
            Console.WriteLine()
            Console.Write("Your Choice 你的选择: ")
            LangSelect = Console.ReadLine()
        End While
        Console.WriteLine()
        If LangSelect = "1" Then English()
        If LangSelect = "2" Then Chinese()
    End Sub
End Module
