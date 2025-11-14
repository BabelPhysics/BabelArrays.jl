#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2025-11-07 15:10:08
  @ license: MIT
  @ language: Julia
  @ declaration: Mutable arrays running in kernel on any devices.
  @ description:
 =#

using JSON
using OrderedCollections

kVSCSettingsPath = joinpath(".vscode", "settings.json")

kAutoHeader::OrderedDict{String, Any} = OrderedDict(
    "format" => OrderedDict("startWith" => "#=", "middleWith" => "", "endWith" => "=#", "headerPrefix" => "@"),
    "header" => OrderedDict(
        "author" => "ChenyuBao <chenyu.bao@outlook.com>",
        "date" => OrderedDict("type" => "createTime", "format" => "YYYY-MM-DD HH:mm:ss"),
        "license" => "MIT",
        "language" => "Julia",
        "declaration" => "Mutable arrays running in kernel on any devices.",
        "description" => "",
    ),
)

function main()::Nothing
    settings = OrderedDict{String, Any}()
    settings["autoHeader"] = kAutoHeader
    isdir(".vscode") || mkpath(".vscode")
    open(kVSCSettingsPath, "w") do io
        JSON.print(io, settings, 4)
    end
    return nothing
end

main()
