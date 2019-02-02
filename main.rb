
#funcao que polariza a frase
private def polarizarFrase(frase, lemas)

	#tokenizar a frase num array de tokens
	vetTokens = tokenizeFrase(frase)

	#quantidade de tokens validos
	tokensValidos = 0

	#quantidade de tokens de acordo com o rotulo
	tokensNeg = 0
	tokensNeu = 0
	tokensPos = 0

	vetTokens.each_index do |idx|

		#procura se o token e' valido (se existe no vetor de flexoes)
		tokenValido = procurarLema(lemas, vetTokens[idx])

		if tokenValido.length > 0
			tokenValido.each do |idxToken|
				print "#{lemas[idxToken]}\n"
	 
				rotulo1 = lemas[idxToken][2]
				rotulo2 = lemas[idxToken][3]

				if rotulo1 == "-1" || rotulo2 == "-1"
					tokensNeg += 1
				end
				if rotulo1 == "0" || rotulo2 == "0"
					tokensNeu += 1
				end
				if rotulo1 == "1" || rotulo2 == "1"
					tokensPos += 1
				end

				tokensValidos += 1				
			end # each
		end # if
	end #each_index

	#caso nenhum token seja encontrado
	if tokensValidos < 1 
		return nil
	
	#caso haja tokens validos
	else
		puts "neg: #{tokensNeg}, neu: #{tokensNeu}, pos: #{tokensPos}"

		# divisao = tokensValidos
		divisao = tokensNeg + tokensNeu + tokensPos

		#probabilidade dos rotulos
		pRotulos = Array.new(3)
		pRotulos[0] = tokensNeg/divisao.to_f #probabilidade de ser negativo
		pRotulos[1] = tokensNeu/divisao.to_f #probabilidade de ser neutro
		pRotulos[2] = tokensPos/divisao.to_f #probabilidade de ser positivo

		puts "probabilidades: #{pRotulos} | token validos: #{tokensValidos}"

		#saber qnts probabilidades foram zero
		qntZeros = 0
		pRotulos.each_index do |idx|
			if pRotulos[idx] == 0
				qntZeros += 1
			end
		end

		#isso significa que nao ha probabilidades zeradas
		if qntZeros == 0
			
			#caso as três probabilidades sejam iguais
			if pRotulos[0] == pRotulos[1] && pRotulos[1] == pRotulos[2]
				return "neg,neu,pos"
			end

			#procura qual a maior probabilidade
			maior = 0
			idxMaior = nil
			pRotulos.each_index do |idx|
				if pRotulos[idx] > maior
					maior = pRotulos[idx]
					idxMaior = idx
				end
			end #each_index

			if idxMaior == 0
				return "neg"
			elsif idxMaior == 1
				return "neu"
			elsif idxMaior == 2
				return "pos"
			end

		#isso significa que so ha uma probabilidade zerada
		elsif qntZeros == 1
			if pRotulos[0] == pRotulos[1]
				return "neg,neu"
			end

			if pRotulos[0] == pRotulos[2]
				return "neg,pos"
			end

			if pRotulos[1] == pRotulos[2]
				return "neu,pos"
			end

			#procura qual a maior probabilidade
			maior = 0
			idxMaior = nil
			pRotulos.each_index do |idx|
				if pRotulos[idx] > maior
					maior = pRotulos[idx]
					idxMaior = idx
				end
			end #each_index

			if idxMaior == 0
				return "neg"
			elsif idxMaior == 1
				return "neu"
			elsif idxMaior == 2
				return "pos"
			end

		#isso significa que há duas probabilidades zeradas
		elsif qntZeros == 2

			#procura qual a maior probabilidade
			maior = 0
			idxMaior = nil
			pRotulos.each_index do |idx|
				if pRotulos[idx] > maior
					maior = pRotulos[idx]
					idxMaior = idx
				end
			end #each_index

			if idxMaior == 0
				return "neg"
			elsif idxMaior == 1
				return "neu"
			elsif idxMaior == 2
				return "pos"
			end
		end #else qnt zeros
	end #else tokens validos
end #polarizarFrase()

#funcao para atomizar a frase
private def tokenizeFrase(frase)
	#remove pontuacao, exceto @ e #
	fraseTemp = frase.gsub(/[!$%&*()-=_+|;':",.<>?]/, '')

	#elimina [
	fraseTemp = fraseTemp.gsub(/\[/, '')

	#elimina ]
	fraseTemp = fraseTemp.gsub(/\]/, '')

	#codifica para utf-8
	fraseTemp = fraseTemp.force_encoding('utf-8')

	#converte para minusculo
	fraseTemp = fraseTemp.downcase

	#separa por espacos
	fraseTemp = fraseTemp.split()

	# print fraseTemp
	# puts
	
	return fraseTemp
end #tokenizeFrase()

#funcao que retorna os indexs do lema no vetor de lemas ou vazio caso nao exista
private def procurarLema(vetLemasFlex, lemaTweet, inicio = 0, fim = 1)
	# o array eh desta forma Array(lemas, polarizacao1, polarizacao2)
	# SentiLex-PT2 tem apenas dois lemas, mas o Onto-PT tem muitos lemas
	
	# array com os indexs
	idxLema = []

	# itera no array inteiro (pois pode haver o lema mais de uma vez)
	vetLemasFlex.each_index do |i|

		# itera apenas no range de lemas a procura/comparando com o lema da frase
		(inicio..fim).each do |tokenLema|
			if vetLemasFlex[i][tokenLema] == lemaTweet
				idxLema.push(i)
				break # evita a duplicacao de lemas agrupados com a mesma polarizacao
			end
		end
	end

	return idxLema
	# return vetLemasFlex.find_index{ |meuLema| meuLema[0] == lema || meuLema[1] == lema}
end # procurarLema()

# metodo para ler o arquivos de polarizacao de sentimentos
# retorna Array(lemas, polarizacao1, polarizacao2)
private def lerAqruivoPolarizacao(src)

	#arquivoExterno = File.open(src, "r", :encoding => 'utf-8')
	arquivoExterno = File.open(src, "r")

	arquivoSentiLexFlex = []
	controle = 0

	while linha = arquivoExterno.gets
		temp = ""
		linha = linha.chop
		linha = linha.force_encoding('utf-8')
		pol1, pol2 = "nil", "nil"

		#separa o lema de seus atributos
		linha = linha.split(".")

		#separa as flexoes
		temp2 = linha[0].split(",")

		#concatena as flexoes
		temp += "#{temp2[0]};#{temp2[1]};"

		#separa os atributos (4 atributos)
		linha = linha[1].split(";")

		# verifica qual das strings do array tem 'POL', e armazena as polariacoes em pol1 e pol2
		linha.each do |i|
			if i.include?("POL")
				pol1 == "nil" ? pol1 = i.split("=")[1] : pol2 = i.split("=")[1]
			end
		end

		temp += "#{pol1};#{pol2}"

		# dá push como array
		arquivoSentiLexFlex.push(temp.split(";"))
		controle += 1

	end #while

	return arquivoSentiLexFlex
end #lerAqruivoPolarizacao()

# frase = "Agência atribui a medida ao acordo entre a Embraer e a Boeing para criar uma joint venture. Presidente Bolsonaro autoriza fusão entre Embraer e Boeing Reprodução/JN A agência de classificação de risco Moody's colocou nesta sexta-feira (1) o rating Ba1 da Embraer em revisão para elevação. A Moody's atribui a medida ao acordo entre a Embraer e a Boeing para criar uma joint venture que vai concentrar as áreas de aviação comercial e serviços da Embraer. A Boeing controlará a parceria com uma fatia de 80%, enquanto a Embraer terá os 20% restantes. Segundo a agência, a alavancagem da Embraer cairá significativamente, enquanto a liquidez vai melhorar."
# frase = "Preço caí médio da gasolina nas bombas cai pela 15ª vez seguida, diz ANP"
frase = "tristeza enorme, essa que aconteceu em Brumadinho."
sentiLexPT2 = lerAqruivoPolarizacao("/Users/paulinelymorgan/Dropbox/RailsServer/ft/public/SentiLex-flex-PT02.txt")

# puts polarizarFrase(frase, sentiLexPT2)

