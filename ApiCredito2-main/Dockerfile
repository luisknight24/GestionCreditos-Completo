# ---------- Build stage ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiamos la solución (archivo correcto)
COPY GestionIntApi.slnx ./

# Copiamos solo el proyecto
COPY GestionIntApi/GestionIntApi.csproj GestionIntApi/

# Restauramos dependencias del proyecto
RUN dotnet restore GestionIntApi/GestionIntApi.csproj

# Copiamos todo el resto
COPY . ./

# Publicamos el proyecto
WORKDIR /app/GestionIntApi
RUN dotnet publish -c Release -o /out

# ---------- Runtime stage ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out ./

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "GestionIntApi.dll"]

