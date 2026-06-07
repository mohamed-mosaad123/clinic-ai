FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["Clinic Project.csproj", "./"]
RUN dotnet restore "Clinic Project.csproj"

COPY . .
RUN dotnet publish "Clinic Project.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Clinic Project.dll"]
